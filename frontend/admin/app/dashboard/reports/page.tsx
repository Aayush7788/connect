"use client";

import { useQuery } from "@tanstack/react-query";
import { useState } from "react";
import { api, errorMessage } from "@/lib/api";
import { EmptyState, ErrorState, LoadingState } from "@/components/page-state";
import { StatusBadge } from "@/components/status-badge";
import { formatDate, formatLabel } from "@/lib/format";

const statuses = ["submitted", "in_review", "resolved_no_action", "action_taken", "dismissed"] as const;

export default function ReportsPage() {
  const [status, setStatus] = useState<(typeof statuses)[number]>("submitted");
  const [grouped, setGrouped] = useState(true);
  const reports = useQuery({
    queryKey: ["admin", "reports", status, grouped],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/reports", { params: { query: { status, grouped, limit: 100 } } });
      if (error) throw error;
      return data;
    },
  });

  return (
    <>
      <header className="page-header"><div><h1>Reports</h1><p>Inspect repeated safety and data-quality reports by target.</p></div></header>
      <div className="toolbar">
        <div className="field"><label htmlFor="report-status">Status</label><select id="report-status" value={status} onChange={(event) => setStatus(event.target.value as typeof status)}>{statuses.map((value) => <option key={value} value={value}>{formatLabel(value)}</option>)}</select></div>
        <label className="field" style={{ display: "flex", gridTemplateColumns: "auto 1fr", alignItems: "center", minHeight: 42 }}><input type="checkbox" checked={grouped} onChange={(event) => setGrouped(event.target.checked)} style={{ width: 18, minHeight: 18 }} /><span>Group matching reports</span></label>
      </div>
      <section className="panel">
        {reports.isLoading ? <LoadingState label="Loading reports..." /> : reports.error ? <div className="panel-body"><ErrorState message={errorMessage(reports.error)} /></div> : !reports.data?.items.length ? <EmptyState label="No reports match this view." /> : (
          <div className="table-wrap"><table><thead><tr><th>Target</th><th>Reason</th><th>Reports</th><th>Latest</th><th>Status</th></tr></thead><tbody>
            {reports.data.items.map((item, index) => <tr key={item.id ?? `${item.reported_entity_id}-${item.reason}-${index}`}><td><strong>{formatLabel(item.reported_entity_type)}</strong><div className="metric-label">{item.reported_entity_id}</div></td><td>{formatLabel(item.reason)}</td><td>{item.report_count}</td><td>{formatDate(item.latest_reported_at)}</td><td>{item.status ? <StatusBadge value={item.status} /> : <span className="status">Grouped</span>}</td></tr>)}
          </tbody></table></div>
        )}
      </section>
    </>
  );
}
