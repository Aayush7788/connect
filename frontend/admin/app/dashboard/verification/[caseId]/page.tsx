"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { ArrowLeft, ExternalLink, ShieldCheck } from "lucide-react";
import Link from "next/link";
import { useParams } from "next/navigation";
import { useState } from "react";
import { api, errorMessage } from "@/lib/api";
import { ErrorState, LoadingState } from "@/components/page-state";
import { StatusBadge } from "@/components/status-badge";
import { formatDate, formatLabel } from "@/lib/format";

type Decision = "approve" | "request-changes" | "reject";

export default function VerificationDetailPage() {
  const { caseId } = useParams<{ caseId: string }>();
  const queryClient = useQueryClient();
  const [notes, setNotes] = useState("");
  const detail = useQuery({
    queryKey: ["admin", "verification", caseId],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/verification-cases/{case_id}", { params: { path: { case_id: caseId } } });
      if (error) throw error;
      return data;
    },
  });
  const decision = useMutation({
    mutationFn: async (action: Decision) => {
      const path = action === "approve"
        ? "/admin/verification-cases/{case_id}/approve" as const
        : action === "request-changes"
          ? "/admin/verification-cases/{case_id}/request-changes" as const
          : "/admin/verification-cases/{case_id}/reject" as const;
      const { data, error } = await api.POST(path, { params: { path: { case_id: caseId } }, body: { notes: notes.trim() || undefined } });
      if (error) throw error;
      return data;
    },
    onSuccess: async () => {
      setNotes("");
      await queryClient.invalidateQueries({ queryKey: ["admin", "verification"] });
    },
  });

  if (detail.isLoading) return <LoadingState label="Loading verification evidence..." />;
  if (detail.error || !detail.data) return <ErrorState message={errorMessage(detail.error)} />;
  const item = detail.data;
  const isPending = item.status === "pending_review";

  return (
    <>
      <header className="page-header">
        <div><Link className="table-link" href="/dashboard/verification"><ArrowLeft size={15} /> Back to queue</Link><h1 style={{ marginTop: 12 }}>{item.profile.display_name}</h1><p>{formatLabel(item.profile.role)} verification review</p></div>
        <StatusBadge value={item.status} />
      </header>
      {decision.error && <ErrorState message={errorMessage(decision.error)} />}
      <div className="detail-grid">
        <div className="section-stack" style={{ marginTop: 0 }}>
          <section className="panel"><div className="panel-header"><h2>Profile details</h2><StatusBadge value={item.profile.verification_status} /></div><div className="panel-body">
            <dl className="key-values"><dt>Role</dt><dd>{formatLabel(item.profile.role)}</dd><dt>Mobile</dt><dd>{item.owner_mobile ?? "Not available"}</dd><dt>Address</dt><dd>{item.full_address ?? "Not available"}</dd><dt>Completion</dt><dd>{item.profile.completion_score}%</dd><dt>Submitted</dt><dd>{formatDate(item.submitted_at)}</dd><dt>Resubmissions</dt><dd>{item.resubmission_count ?? 0}</dd></dl>
          </div></section>
          <section className="panel"><div className="panel-header"><h2>Review checklist</h2></div><div className="panel-body check-list">
            {(item.checks ?? []).map((check) => <div className="check-row" key={check.check_type}><div><strong>{formatLabel(check.check_type)}</strong>{check.notes_to_user && <div className="metric-label" style={{ marginTop: 5 }}>{check.notes_to_user}</div>}</div><StatusBadge value={check.status} /></div>)}
          </div></section>
          <section className="panel"><div className="panel-header"><h2>Private evidence</h2><span className="status">15-minute access</span></div><div className="panel-body proof-list">
            {!item.private_document_access?.length ? <p className="metric-label">No optional proof documents were submitted.</p> : item.private_document_access.map((document) => (
              <a key={document.media_asset_id} className="proof-link" href={document.access_url} target="_blank" rel="noreferrer"><span>{document.safe_display_name}</span><ExternalLink size={17} /></a>
            ))}
          </div></section>
        </div>
        <aside className="panel"><div className="panel-header"><h2>Decision</h2><ShieldCheck size={18} /></div><div className="panel-body">
          {item.notes_to_user && <div className="error" style={{ marginBottom: 14 }}><strong>Owner message</strong><div style={{ marginTop: 5 }}>{item.notes_to_user}</div></div>}
          <div className="field"><label htmlFor="notes">Review notes</label><textarea id="notes" value={notes} onChange={(event) => setNotes(event.target.value)} placeholder="Required when requesting changes or rejecting." disabled={!isPending || decision.isPending} /></div>
          <div className="button-row" style={{ marginTop: 14 }}>
            <button className="button button-primary" disabled={!isPending || decision.isPending} onClick={() => decision.mutate("approve")}>Approve</button>
            <button className="button button-secondary" disabled={!isPending || decision.isPending || !notes.trim()} onClick={() => decision.mutate("request-changes")}>Request changes</button>
            <button className="button button-danger" disabled={!isPending || decision.isPending || !notes.trim()} onClick={() => decision.mutate("reject")}>Reject</button>
          </div>
          {!isPending && <p className="metric-label" style={{ marginTop: 14 }}>This case already has a final review state.</p>}
        </div></aside>
      </div>
    </>
  );
}
