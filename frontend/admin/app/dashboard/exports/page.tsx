"use client";

import { useMutation } from "@tanstack/react-query";
import { Download } from "lucide-react";
import { useState } from "react";
import { api, errorMessage } from "@/lib/api";
import { ErrorState } from "@/components/page-state";
import { formatDate, formatLabel } from "@/lib/format";

const datasets = ["profiles", "verification_cases", "reports", "search_summary", "contact_summary"] as const;

export default function ExportsPage() {
  const [dataset, setDataset] = useState<(typeof datasets)[number]>("profiles");
  const createExport = useMutation({
    mutationFn: async () => {
      const { data, error } = await api.POST("/admin/exports", { body: { dataset, filters: {} } });
      if (error) throw error;
      return data;
    },
  });

  return (
    <>
      <header className="page-header"><div><h1>CSV exports</h1><p>Generate a private, short-lived operational export without proof-document URLs.</p></div></header>
      <section className="panel"><div className="panel-body">
        {createExport.error && <div style={{ marginBottom: 14 }}><ErrorState message={errorMessage(createExport.error)} /></div>}
        <div className="toolbar">
          <div className="field"><label htmlFor="dataset">Dataset</label><select id="dataset" value={dataset} onChange={(event) => setDataset(event.target.value as typeof dataset)}>{datasets.map((value) => <option key={value} value={value}>{formatLabel(value)}</option>)}</select></div>
          <button className="button button-primary" onClick={() => createExport.mutate()} disabled={createExport.isPending}><Download size={17} /> {createExport.isPending ? "Generating..." : "Generate export"}</button>
        </div>
        {createExport.data && <div className="notice" style={{ marginTop: 18 }}><strong>Export ready</strong><p className="metric-label">Link expires {formatDate(createExport.data.expires_at)}.</p><a className="button button-secondary" href={createExport.data.download_url} target="_blank" rel="noreferrer"><Download size={17} /> Download CSV</a></div>}
      </div></section>
    </>
  );
}
