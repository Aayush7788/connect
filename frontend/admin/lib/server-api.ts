export const accessCookieName = "connect_admin_access";

export function backendUrl(path: string): string {
  const base = process.env.ADMIN_BACKEND_API_URL ?? "http://127.0.0.1:8001/v1";
  return `${base.replace(/\/$/, "")}/${path.replace(/^\//, "")}`;
}

export async function parseBackendResponse(response: Response) {
  const text = await response.text();
  const body = text ? JSON.parse(text) : null;
  return { body, text };
}
