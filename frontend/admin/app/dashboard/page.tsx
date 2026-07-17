"use client";

import { useQuery } from "@tanstack/react-query";
import { api, errorMessage } from "@/lib/api";
import { EmptyState, ErrorState, LoadingState } from "@/components/page-state";
import { formatLabel } from "@/lib/format";

export default function DashboardPage() {
  const summary = useQuery({
    queryKey: ["admin", "analytics"],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/analytics/summary");
      if (error) throw error;
      return data;
    },
  });

  if (summary.isLoading) return <LoadingState label="Loading operations summary..." />;
  if (summary.error || !summary.data) return <ErrorState message={errorMessage(summary.error)} />;

  const data = summary.data;
  const metrics = [
    ["Total profiles", data.total_profiles],
    ["Verified profiles", data.verified_profiles],
    ["Pending verification", data.pending_verifications],
    ["Open reports", data.submitted_reports],
  ] as const;

  return (
    <>
      <header className="page-header">
        <div><h1>Operations overview</h1><p>Current marketplace and review activity.</p></div>
      </header>
      <section className="metric-grid" aria-label="Marketplace metrics">
        {metrics.map(([label, value]) => (
          <article className="metric" key={label}>
            <div className="metric-label">{label}</div>
            <div className="metric-value">{value.toLocaleString("en-IN")}</div>
          </article>
        ))}
      </section>
      <div className="section-stack">
        <section className="panel">
          <div className="panel-header"><h2>Top search terms</h2><span className="status">Latest aggregate</span></div>
          {data.top_search_terms.length === 0 ? <EmptyState label="No search activity yet." /> : (
            <div className="table-wrap"><table><thead><tr><th>Search term</th><th>Searches</th></tr></thead><tbody>
              {data.top_search_terms.map((item) => <tr key={item.term}><td>{item.term}</td><td>{item.count.toLocaleString("en-IN")}</td></tr>)}
            </tbody></table></div>
          )}
        </section>
        <section className="panel">
          <div className="panel-header"><h2>Contact actions</h2><span className="status">{data.profile_views.toLocaleString("en-IN")} profile views</span></div>
          {Object.keys(data.contact_actions).length === 0 ? <EmptyState label="No contact actions yet." /> : (
            <div className="table-wrap"><table><thead><tr><th>Action</th><th>Count</th></tr></thead><tbody>
              {Object.entries(data.contact_actions).map(([action, count]) => <tr key={action}><td>{formatLabel(action)}</td><td>{count.toLocaleString("en-IN")}</td></tr>)}
            </tbody></table></div>
          )}
        </section>
      </div>
    </>
  );
}
