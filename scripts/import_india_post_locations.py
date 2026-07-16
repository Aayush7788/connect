from __future__ import annotations

import argparse
import csv
from pathlib import Path
import sys
import tempfile

import httpx
from sqlalchemy import create_engine


REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = REPO_ROOT / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from app.core.config import get_settings  # noqa: E402


DEFAULT_SOURCE_URL = (
    "https://www.data.gov.in/sites/default/files/dataurl03122020/pincode.csv"
)


def download(source_url: str, destination: Path) -> None:
    headers = {
        "User-Agent": "Connect-Location-Importer/1.0",
        "Referer": "https://www.data.gov.in/",
    }
    with httpx.stream(
        "GET", source_url, headers=headers, follow_redirects=True, timeout=120
    ) as response:
        response.raise_for_status()
        with destination.open("wb") as target:
            for chunk in response.iter_bytes():
                target.write(chunk)


def valid_row(row: dict[str, str]) -> bool:
    pincode = (row.get("Pincode") or "").strip()
    return bool(
        len(pincode) == 6
        and pincode.isdigit()
        and (row.get("StateName") or "").strip()
        and (row.get("District") or "").strip()
        and (row.get("OfficeName") or "").strip()
    )


def import_csv(csv_path: Path, database_url: str) -> dict[str, int]:
    engine = create_engine(database_url, pool_pre_ping=True)
    raw = engine.raw_connection()
    try:
        cursor = raw.cursor()
        cursor.execute(
            """
            create temporary table india_post_stage (
                state_name text not null,
                district_name text not null,
                office_name text not null,
                pincode varchar(6) not null,
                delivery text
            ) on commit drop
            """
        )
        loaded = 0
        with csv_path.open("r", encoding="utf-8-sig", newline="") as source:
            reader = csv.DictReader(source)
            with cursor.copy(
                "copy india_post_stage "
                "(state_name, district_name, office_name, pincode, delivery) "
                "from stdin"
            ) as copy:
                for row in reader:
                    if not valid_row(row):
                        continue
                    copy.write_row(
                        (
                            row["StateName"].strip(),
                            row["District"].strip(),
                            row["OfficeName"].strip(),
                            row["Pincode"].strip(),
                            (row.get("Delivery") or "").strip(),
                        )
                    )
                    loaded += 1

        cursor.execute(
            """
            insert into location_states (name, normalized_name)
            select
                min(initcap(lower(trim(state_name)))),
                lower(regexp_replace(trim(state_name), '[^[:alnum:]]+', ' ', 'g'))
            from india_post_stage
            group by lower(
                regexp_replace(trim(state_name), '[^[:alnum:]]+', ' ', 'g')
            )
            on conflict (normalized_name) do update set name = excluded.name
            where location_states.name is distinct from excluded.name
            """
        )
        cursor.execute(
            """
            insert into location_districts (state_id, name, normalized_name)
            select
                states.id,
                min(initcap(lower(trim(stage.district_name)))),
                lower(regexp_replace(trim(stage.district_name), '[^[:alnum:]]+', ' ', 'g'))
            from india_post_stage stage
            join location_states states
              on states.normalized_name = lower(
                regexp_replace(trim(stage.state_name), '[^[:alnum:]]+', ' ', 'g')
              )
            group by states.id, lower(
                regexp_replace(trim(stage.district_name), '[^[:alnum:]]+', ' ', 'g')
            )
            on conflict (state_id, normalized_name)
            do update set name = excluded.name
            where location_districts.name is distinct from excluded.name
            """
        )
        cursor.execute(
            """
            with ranked as (
                select
                    stage.pincode,
                    states.id as state_id,
                    districts.id as district_id,
                    lower(stage.delivery) = 'delivery' as is_delivery,
                    row_number() over (
                        partition by stage.pincode
                        order by (lower(stage.delivery) = 'delivery') desc,
                                 stage.district_name,
                                 stage.office_name
                    ) as choice
                from india_post_stage stage
                join location_states states
                  on states.normalized_name = lower(
                    regexp_replace(trim(stage.state_name), '[^[:alnum:]]+', ' ', 'g')
                  )
                join location_districts districts
                  on districts.state_id = states.id
                 and districts.normalized_name = lower(
                    regexp_replace(trim(stage.district_name), '[^[:alnum:]]+', ' ', 'g')
                 )
            )
            insert into postal_codes (pincode, state_id, district_id, is_delivery)
            select pincode, state_id, district_id, is_delivery
            from ranked
            where choice = 1
            on conflict (pincode) do update
            set state_id = excluded.state_id,
                district_id = excluded.district_id,
                is_delivery = excluded.is_delivery,
                updated_at = now()
            where (postal_codes.state_id, postal_codes.district_id, postal_codes.is_delivery)
                is distinct from
                (excluded.state_id, excluded.district_id, excluded.is_delivery)
            """
        )
        cursor.execute(
            """
            insert into postal_areas (pincode, name, normalized_name)
            select
                stage.pincode,
                min(initcap(lower(trim(stage.office_name)))),
                lower(regexp_replace(trim(stage.office_name), '[^[:alnum:]]+', ' ', 'g'))
            from india_post_stage stage
            join postal_codes codes on codes.pincode = stage.pincode
            group by stage.pincode, lower(
                regexp_replace(trim(stage.office_name), '[^[:alnum:]]+', ' ', 'g')
            )
            on conflict (pincode, normalized_name)
            do update set name = excluded.name
            where postal_areas.name is distinct from excluded.name
            """
        )
        cursor.execute(
            """
            update profiles profile
            set state_id = codes.state_id,
                district_id = codes.district_id,
                state = states.name,
                city = districts.name,
                location_validation_status = 'warning',
                location_validated_at = now()
            from postal_codes codes
            join location_states states on states.id = codes.state_id
            join location_districts districts on districts.id = codes.district_id
            where profile.pincode = codes.pincode
              and lower(regexp_replace(trim(profile.state), '[^[:alnum:]]+', ' ', 'g'))
                  = states.normalized_name
              and lower(regexp_replace(trim(profile.city), '[^[:alnum:]]+', ' ', 'g'))
                  = districts.normalized_name
              and (
                profile.state_id is distinct from codes.state_id
                or profile.district_id is distinct from codes.district_id
                or profile.location_validation_status = 'unvalidated'
              )
            """
        )
        profiles_backfilled = cursor.rowcount
        cursor.execute(
            """
            select
              (select count(*) from location_states),
              (select count(*) from location_districts),
              (select count(*) from postal_codes),
              (select count(*) from postal_areas)
            """
        )
        states, districts, pincodes, areas = cursor.fetchone()
        raw.commit()
        return {
            "source_rows": loaded,
            "states": states,
            "districts": districts,
            "pincodes": pincodes,
            "areas": areas,
            "profiles_backfilled": profiles_backfilled,
        }
    except Exception:
        raw.rollback()
        raise
    finally:
        raw.close()
        engine.dispose()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-url", default=DEFAULT_SOURCE_URL)
    parser.add_argument("--csv", type=Path)
    arguments = parser.parse_args()
    database_url = get_settings().database_url
    if database_url is None:
        raise RuntimeError("DATABASE_URL is required.")

    if arguments.csv:
        result = import_csv(arguments.csv, database_url.get_secret_value())
    else:
        with tempfile.TemporaryDirectory() as directory:
            csv_path = Path(directory) / "india-post-pincodes.csv"
            download(arguments.source_url, csv_path)
            result = import_csv(csv_path, database_url.get_secret_value())
    print(result)


if __name__ == "__main__":
    main()
