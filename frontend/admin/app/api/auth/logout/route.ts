import { cookies } from "next/headers";
import { NextResponse } from "next/server";
import {
  accessCookieName,
  backendUrl,
} from "@/lib/server-api";

export async function POST() {
  const cookieStore = await cookies();
  const token = cookieStore.get(accessCookieName)?.value;
  if (token) {
    await fetch(backendUrl("auth/logout"), {
      method: "POST",
      headers: { authorization: `Bearer ${token}` },
      cache: "no-store",
    }).catch(() => undefined);
  }
  const response = NextResponse.json({ ok: true });
  response.cookies.delete(accessCookieName);
  return response;
}
