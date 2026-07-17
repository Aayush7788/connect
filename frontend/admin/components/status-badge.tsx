export function StatusBadge({ value }: { value: string | null | undefined }) {
  const normalized = value ?? "unknown";
  const positive = new Set(["verified", "approved", "active", "public", "ready"]);
  const warning = new Set(["pending", "pending_review", "changes_requested", "draft", "unverified"]);
  const negative = new Set(["rejected", "suspended", "suspended_by_admin", "failed", "deleted"]);
  const tone = positive.has(normalized)
    ? "status-green"
    : warning.has(normalized)
      ? "status-amber"
      : negative.has(normalized)
        ? "status-red"
        : "";
  return <span className={`status ${tone}`}>{normalized.replaceAll("_", " ")}</span>;
}
