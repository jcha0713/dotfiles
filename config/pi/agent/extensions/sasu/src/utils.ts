export function truncateText(text: string, maxChars: number): { text: string; truncated: boolean } {
  if (text.length <= maxChars) return { text, truncated: false };
  const omitted = text.length - maxChars;
  return {
    text: `${text.slice(0, maxChars)}\n\n[... truncated ${omitted} characters ...]`,
    truncated: true,
  };
}

export function compactLines(lines: string[], maxLines: number): string[] {
  if (lines.length <= maxLines) return lines;
  const omitted = lines.length - maxLines;
  return [...lines.slice(0, maxLines), `... (${omitted} more)`];
}

export function shellEscape(value: string): string {
  return `'${value.replace(/'/g, `'"'"'`)}'`;
}

export function previewText(text: string, maxChars: number): string {
  const compact = text.replace(/\s+/g, " ").trim();
  if (compact.length <= maxChars) return compact;
  if (maxChars <= 1) return "…";
  return `${compact.slice(0, maxChars - 1).trimEnd()}…`;
}
