export function LoadingState({ label = "Loading..." }: { label?: string }) {
  return <div className="loading">{label}</div>;
}

export function EmptyState({ label }: { label: string }) {
  return <div className="empty">{label}</div>;
}

export function ErrorState({ message }: { message: string }) {
  return <div className="error">{message}</div>;
}
