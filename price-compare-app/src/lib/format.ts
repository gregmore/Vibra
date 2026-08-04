export function formatCurrency(value: number): string {
  return `¥${value.toFixed(2)}`;
}

export function formatCompactNumber(value?: number): string {
  if (!value) {
    return "N/A";
  }

  if (value >= 10000) {
    return `${(value / 10000).toFixed(1)}w`;
  }

  if (value >= 1000) {
    return `${(value / 1000).toFixed(1)}k`;
  }

  return `${value}`;
}

export function formatPercentage(value: number): string {
  return `${Math.round(value * 100)}%`;
}

export function formatTime(value: string): string {
  return new Date(value).toLocaleString();
}
