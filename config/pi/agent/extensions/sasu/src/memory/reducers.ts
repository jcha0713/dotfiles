import type { MemoryEvent, WorkingStateByKey } from "./types";

function asString(value: unknown): string | null {
	if (typeof value !== "string") return null;
	const trimmed = value.trim();
	return trimmed.length > 0 ? trimmed : null;
}

function asStringArray(value: unknown): string[] {
	if (!Array.isArray(value)) return [];
	return value
		.map((item) => (typeof item === "string" ? item.trim() : ""))
		.filter((item) => item.length > 0);
}

function dedupeSorted(values: string[]): string[] {
	return Array.from(new Set(values)).sort((a, b) => a.localeCompare(b));
}

function deriveManualFocus(event: MemoryEvent): string | null {
	return (
		asString(event.payload.focus) ??
		asString(event.payload.goal) ??
		asString(event.payload.intent) ??
		asString(event.payload.label)
	);
}

function deriveExplicitIntent(event: MemoryEvent): string | null {
	return asString(event.payload.intent) ?? asString(event.payload.goal) ?? asString(event.payload.message);
}

function applyCheckResult(
	previous: WorkingStateByKey["last_checks"] | undefined,
	event: MemoryEvent,
): WorkingStateByKey["last_checks"] {
	const name = asString(event.payload.name) ?? asString(event.payload.command) ?? "check";
	const status = (asString(event.payload.status) ?? asString(event.payload.result) ?? "unknown").toLowerCase();
	const files = dedupeSorted(asStringArray(event.payload.files));
	const nextFailing = [...(previous?.failing ?? [])];
	const nextPassing = [...(previous?.passing ?? [])];

	const withoutName = (entries: Array<{ name: string; files: string[]; status?: string }>) =>
		entries.filter((entry) => entry.name !== name);

	const entry = { name, files, status };
	const isFail = status === "fail" || status === "failed" || status === "error";

	if (isFail) {
		return {
			failing: [...withoutName(nextFailing), entry],
			passing: withoutName(nextPassing),
			updatedAt: event.ts,
		};
	}

	if (status === "pass" || status === "passed" || status === "ok") {
		return {
			failing: withoutName(nextFailing),
			passing: [...withoutName(nextPassing), entry],
			updatedAt: event.ts,
		};
	}

	return {
		failing: withoutName(nextFailing),
		passing: [...withoutName(nextPassing), entry],
		updatedAt: event.ts,
	};
}

export function reduceFromEvent(
	previous: Partial<WorkingStateByKey>,
	event: MemoryEvent,
): Partial<WorkingStateByKey> {
	const next: Partial<WorkingStateByKey> = { ...previous };

	switch (event.kind) {
		case "focus.override.manual":
		case "user.command.goal_set": {
			const label = deriveManualFocus(event);
			if (!label) break;

			next.active_focus = {
				label,
				source: event.kind,
				locked: true,
				updatedAt: event.ts,
			};
			next.intent_hypotheses = {
				hypotheses: [{ label, confidence: 0.95, evidence: [event.kind] }],
				selected: { label, confidence: 0.95, source: "manual_override" },
				needsClarification: false,
			};
			break;
		}
		case "user.intent.explicit": {
			const label = deriveExplicitIntent(event);
			if (!label) break;
			next.intent_hypotheses = {
				hypotheses: [{ label, confidence: 0.85, evidence: [event.kind] }],
				selected: { label, confidence: 0.85, source: "explicit_intent" },
				needsClarification: false,
			};
			if (!next.active_focus?.locked) {
				next.active_focus = {
					label,
					source: event.kind,
					locked: false,
					updatedAt: event.ts,
				};
			}
			break;
		}
		case "code.files.changed": {
			const files = asStringArray(event.payload.files);
			const nextPaths = dedupeSorted([...(next.changed_areas?.paths ?? []), ...files]);
			next.changed_areas = {
				paths: nextPaths,
				updatedAt: event.ts,
			};
			break;
		}
		case "check.run.result": {
			next.last_checks = applyCheckResult(next.last_checks, event);
			break;
		}
		case "agent.review.completed": {
			const summary = asString(event.payload.summary) ?? asString(event.payload.text) ?? asString(event.payload.result);
			if (!summary) break;
			next.last_review_summary = {
				summary,
				evidence: asStringArray(event.payload.evidence),
				updatedAt: event.ts,
			};
			break;
		}
		default:
			break;
	}

	if (!next.open_risks) {
		next.open_risks = [];
	}

	return next;
}

export function rebuildSnapshot(events: MemoryEvent[]): Partial<WorkingStateByKey> {
	const ordered = [...events].sort((a, b) => a.ts.localeCompare(b.ts));
	let snapshot: Partial<WorkingStateByKey> = {};
	for (const event of ordered) {
		snapshot = reduceFromEvent(snapshot, event);
	}
	if (!snapshot.open_risks) snapshot.open_risks = [];
	return snapshot;
}
