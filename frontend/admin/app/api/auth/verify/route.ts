import { NextRequest, NextResponse } from "next/server";
import {
  accessCookieName,
  backendUrl,
  parseBackendResponse,
} from "@/lib/server-api";

export async function POST(request: NextRequest) {
  const authResponse = await fetch(backendUrl("auth/otp/verify"), {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: await request.text(),
    cache: "no-store",
  });
  const { body } = await parseBackendResponse(authResponse);
  if (!authResponse.ok) {
    return NextResponse.json(body, { status: authResponse.status });
  }
  const accessToken = body.access_token as string;
  const adminResponse = await fetch(backendUrl("admin/me"), {
    headers: { authorization: `Bearer ${accessToken}` },
    cache: "no-store",
  });
  const adminBody = await parseBackendResponse(adminResponse);
  if (!adminResponse.ok) {
    return NextResponse.json(adminBody.body, { status: adminResponse.status });
  }
  const response = NextResponse.json(adminBody.body);
  response.cookies.set(accessCookieName, accessToken, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: 60 * 60,
  });
  return response;
}
