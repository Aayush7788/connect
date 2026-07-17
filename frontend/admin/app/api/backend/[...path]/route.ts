import { cookies } from "next/headers";
import { NextRequest, NextResponse } from "next/server";
import { accessCookieName, backendUrl } from "@/lib/server-api";

async function proxy(request: NextRequest, context: { params: Promise<{ path: string[] }> }) {
  const token = (await cookies()).get(accessCookieName)?.value;
  if (!token) {
    return NextResponse.json({ error: { message: "Please login again." } }, { status: 401 });
  }
  const { path } = await context.params;
  const target = new URL(backendUrl(path.join("/")));
  request.nextUrl.searchParams.forEach((value, key) => target.searchParams.append(key, value));
  const hasBody = !["GET", "HEAD"].includes(request.method);
  const response = await fetch(target, {
    method: request.method,
    headers: {
      authorization: `Bearer ${token}`,
      "content-type": request.headers.get("content-type") ?? "application/json",
      "user-agent": request.headers.get("user-agent") ?? "connect-admin",
    },
    body: hasBody ? await request.text() : undefined,
    cache: "no-store",
  });
  const body = await response.arrayBuffer();
  return new NextResponse(body, {
    status: response.status,
    headers: { "content-type": response.headers.get("content-type") ?? "application/json" },
  });
}

export const GET = proxy;
export const POST = proxy;
export const PATCH = proxy;
export const DELETE = proxy;
