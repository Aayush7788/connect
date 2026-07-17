"use client";

import { FormEvent, useState } from "react";
import { useMutation } from "@tanstack/react-query";
import { api, errorMessage } from "@/lib/api";
import { ErrorState } from "@/components/page-state";

type Role = "business" | "job_worker" | "skilled_worker";

export default function SeedProfilePage() {
  const [role, setRole] = useState<Role>("business");
  const [createdName, setCreatedName] = useState<string | null>(null);
  const create = useMutation({
    mutationFn: async (form: HTMLFormElement) => {
      const values = new FormData(form);
      const displayName = String(values.get("display_name") ?? "").trim();
      const profileData: Record<string, string | number> = Object.fromEntries([...values.entries()].filter(([key, value]) => !["display_name", "make_public"].includes(key) && String(value).trim()).map(([key, value]) => [key, String(value).trim()]));
      if (profileData.experience_years) profileData.experience_years = Number(profileData.experience_years);
      const { data, error } = await api.POST("/admin/seed-profiles", { body: { role, display_name: displayName, profile_data: profileData, make_public: values.get("make_public") === "on" } });
      if (error) throw error;
      return data;
    },
    onSuccess: (data) => setCreatedName(data.profile.display_name ?? "seed profile"),
  });

  function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setCreatedName(null);
    create.mutate(event.currentTarget);
  }

  return (
    <>
      <header className="page-header"><div><h1>Seed a profile</h1><p>Create ownerless demo data. Only whitelisted fields are accepted by the backend.</p></div></header>
      <section className="panel"><div className="panel-body">
        {create.error && <div style={{ marginBottom: 14 }}><ErrorState message={errorMessage(create.error)} /></div>}
        {createdName && <div className="status status-green" style={{ marginBottom: 14 }}>Created {createdName}</div>}
        <form onSubmit={submit} className="form-grid">
          <div className="field"><label htmlFor="role">Profile role</label><select id="role" value={role} onChange={(event) => setRole(event.target.value as Role)}><option value="business">Business</option><option value="job_worker">Job worker</option><option value="skilled_worker">Skilled worker</option></select></div>
          <div className="field"><label htmlFor="display_name">Public name</label><input id="display_name" name="display_name" required maxLength={200} /></div>
          {role !== "skilled_worker" && <div className="field"><label htmlFor="owner_name">Owner name</label><input id="owner_name" name="owner_name" /></div>}
          {role === "business" && <><div className="field"><label htmlFor="business_name">Business name</label><input id="business_name" name="business_name" /></div><div className="field span-2"><label htmlFor="manufacture_sell_details">What they manufacture or sell</label><textarea id="manufacture_sell_details" name="manufacture_sell_details" /></div></>}
          {role === "job_worker" && <><div className="field"><label htmlFor="workshop_name">Workshop name</label><input id="workshop_name" name="workshop_name" /></div><div className="field span-2"><label htmlFor="work_summary">Work summary</label><textarea id="work_summary" name="work_summary" /></div></>}
          {role === "skilled_worker" && <div className="field"><label htmlFor="skill_mastery">Primary skill</label><input id="skill_mastery" name="skill_mastery" required /></div>}
          {role !== "business" && <div className="field"><label htmlFor="experience_years">Experience in years</label><input id="experience_years" name="experience_years" type="number" min="0" max="80" /></div>}
          <div className="field"><label htmlFor="alternate_contact_number">Contact number</label><input id="alternate_contact_number" name="alternate_contact_number" inputMode="tel" /></div>
          <div className="field"><label htmlFor="locality">Locality</label><input id="locality" name="locality" /></div>
          <div className="field"><label htmlFor="city">City</label><input id="city" name="city" defaultValue="Surat" /></div>
          <div className="field"><label htmlFor="state">State</label><input id="state" name="state" defaultValue="Gujarat" /></div>
          <div className="field"><label htmlFor="pincode">Pincode</label><input id="pincode" name="pincode" inputMode="numeric" maxLength={6} /></div>
          <div className="field span-2"><label htmlFor="full_address">Full address</label><textarea id="full_address" name="full_address" /></div>
          <label className="field span-2" style={{ display: "flex", gridTemplateColumns: "auto 1fr", alignItems: "center" }}><input name="make_public" type="checkbox" style={{ width: 18, minHeight: 18 }} /><span><strong>Publish immediately</strong><br /><span className="metric-label">Use only for reviewed demo data.</span></span></label>
          <div className="span-2"><button className="button button-primary" disabled={create.isPending}>{create.isPending ? "Creating..." : "Create seed profile"}</button></div>
        </form>
      </div></section>
    </>
  );
}
