from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[3]
OPENAPI_PATH = ROOT / "api" / "openapi.yaml"


def load_openapi() -> dict:
    return yaml.safe_load(OPENAPI_PATH.read_text(encoding="utf-8"))


def test_openapi_contract_parses() -> None:
    spec = load_openapi()

    assert spec["openapi"].startswith("3.")
    assert spec["paths"]
    assert spec["components"]["schemas"]


def test_required_mvp_operations_are_named() -> None:
    spec = load_openapi()
    operation_ids = {
        operation["operationId"]
        for path_item in spec["paths"].values()
        for method, operation in path_item.items()
        if method in {"get", "post", "patch", "delete"}
    }

    required_operation_ids = {
        "requestOtp",
        "verifyOtp",
        "completeBasicAccount",
        "confirmRole",
        "getMe",
        "listCategories",
        "getMyProfile",
        "updateMyProfile",
        "completeMyProfile",
        "hideMyProfile",
        "showMyProfile",
        "searchMarketplace",
        "getProfileDetail",
        "createUploadIntent",
        "submitVerification",
        "createReport",
        "getAdminMe",
    }

    assert required_operation_ids <= operation_ids


def test_search_result_card_does_not_expose_contact_or_full_address() -> None:
    spec = load_openapi()
    search_result = spec["components"]["schemas"]["SearchResult"]
    properties = set(search_result["properties"].keys())

    forbidden_public_card_fields = {
        "mobile",
        "whatsapp_number",
        "contact",
        "address",
        "full_address",
    }

    assert properties.isdisjoint(forbidden_public_card_fields)


def test_profile_update_contract_is_typed_and_role_is_not_editable() -> None:
    spec = load_openapi()
    profile_update = spec["components"]["schemas"]["ProfileUpdateRequest"]
    properties = profile_update["properties"]

    assert profile_update["additionalProperties"] is False
    assert "business_name" in properties
    assert "workshop_name" in properties
    assert "skill_mastery" in properties
    assert "role" not in properties
    assert "primary_mobile" not in properties


def test_media_contract_uses_scoped_multipart_upload_without_private_url() -> None:
    spec = load_openapi()
    upload = spec["components"]["schemas"]["UploadDetails"]
    media = spec["components"]["schemas"]["MediaAsset"]

    assert upload["properties"]["http_method"]["enum"] == ["PUT"]
    assert upload["properties"]["form_field"]["enum"] == ["file"]
    assert media["properties"]["url"]["nullable"] is True
