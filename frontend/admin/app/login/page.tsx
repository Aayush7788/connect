"use client";

import { KeyRound, ShieldCheck } from "lucide-react";
import { FormEvent, useState } from "react";
import { useRouter } from "next/navigation";

function responseMessage(body: unknown): string {
  if (typeof body === "object" && body !== null && "error" in body) {
    const error = body.error as { message?: string };
    return error.message ?? "Unable to login.";
  }
  return "Unable to login.";
}

export default function LoginPage() {
  const router = useRouter();
  const [mobile, setMobile] = useState("");
  const [otp, setOtp] = useState("");
  const [requestId, setRequestId] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function requestOtp(event: FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError(null);
    const response = await fetch("/api/auth/request", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ mobile }),
    });
    const body = await response.json();
    setBusy(false);
    if (!response.ok) {
      setError(responseMessage(body));
      return;
    }
    setRequestId(body.otp_request_id);
  }

  async function verifyOtp(event: FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError(null);
    const response = await fetch("/api/auth/verify", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ mobile, otp, otp_request_id: requestId }),
    });
    const body = await response.json();
    setBusy(false);
    if (!response.ok) {
      setError(responseMessage(body));
      return;
    }
    router.replace("/dashboard");
    router.refresh();
  }

  return (
    <main className="login-shell">
      <section className="login-panel">
        <div className="brand">
          <span className="brand-mark"><ShieldCheck size={20} /></span>
          <span>Connect Admin</span>
        </div>
        <h1 style={{ marginTop: 28, marginBottom: 8, fontSize: 25 }}>Admin sign in</h1>
        <p style={{ color: "var(--muted)", marginTop: 0, marginBottom: 22 }}>
          Use an approved admin mobile number.
        </p>
        {error && <div className="error" style={{ marginBottom: 14 }}>{error}</div>}
        {requestId === null ? (
          <form onSubmit={requestOtp} className="field">
            <label htmlFor="mobile">Mobile number</label>
            <input id="mobile" value={mobile} onChange={(event) => setMobile(event.target.value)} placeholder="+91 98765 43210" inputMode="tel" required />
            <button className="button button-primary" disabled={busy} style={{ marginTop: 12 }}>
              <KeyRound size={17} /> {busy ? "Sending..." : "Send OTP"}
            </button>
          </form>
        ) : (
          <form onSubmit={verifyOtp} className="field">
            <label htmlFor="otp">6-digit OTP</label>
            <input id="otp" value={otp} onChange={(event) => setOtp(event.target.value)} placeholder="Enter OTP" inputMode="numeric" maxLength={6} required />
            <button className="button button-primary" disabled={busy} style={{ marginTop: 12 }}>
              <ShieldCheck size={17} /> {busy ? "Checking..." : "Verify and sign in"}
            </button>
            <button type="button" className="button button-secondary" onClick={() => { setRequestId(null); setOtp(""); }} disabled={busy}>
              Change mobile number
            </button>
          </form>
        )}
      </section>
    </main>
  );
}
