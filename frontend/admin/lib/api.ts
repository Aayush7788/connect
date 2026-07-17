import createClient from "openapi-fetch";
import type { paths } from "@api-schema";

export const api = createClient<paths>({ baseUrl: "/api/backend" });

export function errorMessage(error: unknown): string {
  if (
    typeof error === "object" &&
    error !== null &&
    "error" in error &&
    typeof error.error === "object" &&
    error.error !== null &&
    "message" in error.error
  ) {
    return String(error.error.message);
  }
  return "Unable to complete this action.";
}
