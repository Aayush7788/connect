"use client";

import { useQuery } from "@tanstack/react-query";
import { BarChart3, Download, FileCheck2, Flag, LayoutDashboard, LogOut, UserPlus, Users } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { api } from "@/lib/api";

const navigation = [
  ["/dashboard", "Overview", LayoutDashboard],
  ["/dashboard/verification", "Verification", FileCheck2],
  ["/dashboard/profiles", "Profiles", Users],
  ["/dashboard/seed", "Seed profile", UserPlus],
  ["/dashboard/reports", "Reports", Flag],
  ["/dashboard/exports", "Exports", Download],
] as const;

export function AppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const admin = useQuery({
    queryKey: ["admin", "me"],
    queryFn: async () => {
      const { data, error } = await api.GET("/admin/me");
      if (error) throw error;
      return data;
    },
  });

  async function logout() {
    await fetch("/api/auth/logout", { method: "POST" });
    router.replace("/login");
    router.refresh();
  }

  return (
    <div className="app-layout">
      <aside className="sidebar">
        <div className="brand">
          <span className="brand-mark"><BarChart3 size={19} /></span>
          <span>Connect Admin</span>
        </div>
        <nav className="nav-list" aria-label="Admin navigation">
          {navigation.map(([href, label, Icon]) => (
            <Link key={href} href={href} className={`nav-link ${pathname === href || (href !== "/dashboard" && pathname.startsWith(href)) ? "active" : ""}`}>
              <Icon size={18} /><span>{label}</span>
            </Link>
          ))}
        </nav>
        <div className="sidebar-footer">
          <button className="button button-quiet" onClick={logout}><LogOut size={18} /><span>Log out</span></button>
        </div>
      </aside>
      <div className="main-column">
        <header className="topbar">
          <strong>Operations</strong>
          <div style={{ display: "flex", alignItems: "center", gap: 10 }}><span className="metric-label">{admin.data?.display_name ?? admin.data?.mobile ?? "Admin"}</span><span className="status status-green">Private MVP</span></div>
        </header>
        <main className="content">{children}</main>
      </div>
    </div>
  );
}
