"use client";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { useState } from "react";
import { api, errorMessage } from "@/lib/api";
import { EmptyState, ErrorState, LoadingState } from "@/components/page-state";
import { StatusBadge } from "@/components/status-badge";
import { formatDate, formatLabel } from "@/lib/format";

const statuses = ["pending_review", "changes_requested", "approved", "rejected", "draft"] as const;

export default function VerificationQueuePage() {
  const [status, setStatus] = useState<(typeof statuses)[number]>("pending_review");
  const queue = useQuery({
    queryKey: ["admin", "verification", status],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/verification-cases", { params: { query: { status, limit: 100 } } });
      if (error) throw error;
      return data;
    },
  });

  return (
    <>
      <header className="page-header"><div><h1>Verification queue</h1><p>Review complete profiles before awarding a blue tick.</p></div></header>
      <div className="toolbar">
        <div className="field"><label htmlFor="status">Case status</label><select id="status" value={status} onChange={(event) => setStatus(event.target.value as typeof status)}>
          {statuses.map((value) => <option key={value} value={value}>{formatLabel(value)}</option>)}
        </select></div>
      </div>
      <section className="panel">
        {queue.isLoading ? <LoadingState label="Loading verification cases..." /> : queue.error ? <div className="panel-body"><ErrorState message={errorMessage(queue.error)} /></div> : !queue.data?.items.length ? <EmptyState label="No cases match this status." /> : (
          <div className="table-wrap"><table><thead><tr><th>Profile</th><th>Role</th><th>Reason</th><th>Submitted</th><th>Status</th></tr></thead><tbody>
            {queue.data.items.map((item) => <tr key={item.id}>
              <td><Link className="table-link" href={`/dashboard/verification/${item.id}`}>{item.profile.display_name}</Link></td>
              <td>{formatLabel(item.profile.role)}</td><td>{formatLabel(item.case_reason)}</td><td>{formatDate(item.submitted_at)}</td><td><StatusBadge value={item.status} /></td>
            </tr>)}
          </tbody></table></div>
        )}
      </section>
    </>
  );
}
