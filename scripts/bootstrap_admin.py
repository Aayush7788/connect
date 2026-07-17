import argparse
import sys
from pathlib import Path

from sqlalchemy import select


REPO_ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = REPO_ROOT / "backend"
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from app.db.models.identity import AdminUser, User  # noqa: E402
from app.db.session import create_session_factory  # noqa: E402
from app.modules.auth.service import normalize_mobile  # noqa: E402


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Grant MVP super-admin access to an existing OTP user."
    )
    parser.add_argument("--mobile", required=True)
    parser.add_argument("--display-name", default="Connect Admin")
    args = parser.parse_args()
    mobile = normalize_mobile(args.mobile)

    with create_session_factory()() as session:
        user = session.scalar(
            select(User).where(
                User.primary_mobile == mobile,
                User.account_status != "terminated",
                User.deleted_at.is_(None),
            )
        )
        if user is None:
            print("No active app user found for that mobile. Login in the app first.")
            return 1
        admin = session.scalar(select(AdminUser).where(AdminUser.user_id == user.id))
        if admin is None:
            admin = AdminUser(
                user_id=user.id,
                display_name=args.display_name.strip(),
                role="super_admin",
                status="active",
            )
            session.add(admin)
        else:
            admin.display_name = args.display_name.strip()
            admin.role = "super_admin"
            admin.status = "active"
        session.commit()
        print(f"Admin access enabled for {mobile}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
