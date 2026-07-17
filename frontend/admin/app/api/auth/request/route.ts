import { NextRequest, NextResponse } from "next/server";
import { backendUrl, parseBackendResponse } from "@/lib/server-api";

export async function POST(request: NextRequest) {
  const response = await fetch(backendUrl("auth/otp/request"), {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: await request.text(),
    cache: "no-store",
  });
  const { body } = await parseBackendResponse(response);
  return NextResponse.json(body, { status: response.status });
}
