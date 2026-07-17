"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { api, errorMessage } from "@/lib/api";
import { EmptyState, ErrorState, LoadingState } from "@/components/page-state";
import { StatusBadge } from "@/components/status-badge";
import { formatLabel } from "@/lib/format";

type ProfileFilters = {
  role?: "business" | "job_worker" | "skilled_worker";
  verification_status?: "unverified" | "pending" | "verified" | "changes_requested" | "rejected";
};

export default function ProfilesPage() {
  const queryClient = useQueryClient();
  const [filters, setFilters] = useState<ProfileFilters>({});
  const profiles = useQuery({
    queryKey: ["admin", "profiles", filters],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/profiles", { params: { query: { ...filters, limit: 100 } } });
      if (error) throw error;
      return data;
    },
  });
  const moderation = useMutation({
    mutationFn: async ({ profileId, suspend }: { profileId: string; suspend: boolean }) => {
      if (suspend) {
        const { error } = await api.POST("/admin/profiles/{profile_id}/suspend", { params: { path: { profile_id: profileId } }, body: { notes: "Suspended from the admin profile list." } });
        if (error) throw error;
      } else {
        const { error } = await api.POST("/admin/profiles/{profile_id}/unsuspend", { params: { path: { profile_id: profileId } } });
        if (error) throw error;
      }
    },
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "profiles"] }),
  });

  return (
    <>
      <header className="page-header"><div><h1>Profiles</h1><p>Inspect profile state and remove unsafe accounts from discovery.</p></div></header>
      <div className="toolbar">
        <div className="field"><label htmlFor="role">Role</label><select id="role" value={filters.role ?? ""} onChange={(event) => setFilters((current) => ({ ...current, role: (event.target.value || undefined) as ProfileFilters["role"] }))}><option value="">All roles</option><option value="business">Business</option><option value="job_worker">Job worker</option><option value="skilled_worker">Skilled worker</option></select></div>
        <div className="field"><label htmlFor="verification">Verification</label><select id="verification" value={filters.verification_status ?? ""} onChange={(event) => setFilters((current) => ({ ...current, verification_status: (event.target.value || undefined) as ProfileFilters["verification_status"] }))}><option value="">All states</option><option value="unverified">Unverified</option><option value="pending">Pending</option><option value="verified">Verified</option><option value="changes_requested">Changes requested</option><option value="rejected">Rejected</option></select></div>
      </div>
      {moderation.error && <div style={{ marginBottom: 14 }}><ErrorState message={errorMessage(moderation.error)} /></div>}
      <section className="panel">
        {profiles.isLoading ? <LoadingState label="Loading profiles..." /> : profiles.error ? <div className="panel-body"><ErrorState message={errorMessage(profiles.error)} /></div> : !profiles.data?.items.length ? <EmptyState label="No profiles match these filters." /> : (
          <div className="table-wrap"><table><thead><tr><th>Profile</th><th>Role</th><th>Visibility</th><th>Verification</th><th>Owner</th><th>Source</th><th>Action</th></tr></thead><tbody>
            {profiles.data.items.map((item) => {
              const suspended = item.profile.visibility_status === "suspended_by_admin" || item.account_status === "suspended";
              return <tr key={item.profile.id}><td><strong>{item.profile.display_name}</strong><div className="metric-label">{item.full_address ?? "Address unavailable"}</div></td><td>{formatLabel(item.profile.role)}</td><td><StatusBadge value={item.profile.visibility_status} /></td><td><StatusBadge value={item.profile.verification_status} /></td><td>{item.owner_mobile ?? "Ownerless"}</td><td>{item.is_admin_seeded ? "Admin seeded" : "User entered"}</td><td><button className={`button ${suspended ? "button-secondary" : "button-danger"}`} disabled={moderation.isPending} onClick={() => moderation.mutate({ profileId: item.profile.id, suspend: !suspended })}>{suspended ? "Unsuspend" : "Suspend"}</button></td></tr>;
            })}
          </tbody></table></div>
        )}
      </section>
    </>
  );
}
