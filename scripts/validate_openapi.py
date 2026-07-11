from pathlib import Path
import sys

import yaml


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    spec_path = root / "api" / "openapi.yaml"

    if not spec_path.exists():
        print(f"Missing OpenAPI file: {spec_path}", file=sys.stderr)
        return 1

    try:
        data = yaml.safe_load(spec_path.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:
        print(f"OpenAPI YAML parse failed: {exc}", file=sys.stderr)
        return 1

    if not isinstance(data, dict):
        print("OpenAPI document must be a mapping.", file=sys.stderr)
        return 1

    openapi_version = data.get("openapi")
    paths = data.get("paths")
    components = data.get("components", {})
    schemas = components.get("schemas", {}) if isinstance(components, dict) else {}

    if not isinstance(openapi_version, str) or not openapi_version.startswith("3."):
        print("OpenAPI version must be 3.x.", file=sys.stderr)
        return 1

    if not isinstance(paths, dict) or not paths:
        print("OpenAPI document must contain paths.", file=sys.stderr)
        return 1

    print(f"OpenAPI OK: version={openapi_version}, paths={len(paths)}, schemas={len(schemas)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
