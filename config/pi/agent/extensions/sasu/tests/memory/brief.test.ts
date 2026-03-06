import { describe, expect, it } from "bun:test";
import { buildMissionBrief, resolveIntentContext } from "../../src/memory/brief";

describe("memory/brief", () => {
	it("resolveIntentContext prioritizes active focus lock", () => {
		const resolved = resolveIntentContext({
			workingState: {
				active_focus: {
					label: "Protect review lifecycle semantics",
					source: "focus.override.manual",
					locked: true,
				},
				intent_hypotheses: {
					hypotheses: [{ label: "Different intent", confidence: 0.4, evidence: ["fallback"] }],
					selected: { label: "Different intent", confidence: 0.4, source: "fallback" },
					needsClarification: true,
				},
			},
		});

		expect(resolved.selected?.label).toBe("Protect review lifecycle semantics");
		expect(resolved.selected?.source).toBe("manual_override");
		expect(resolved.selected?.confidence).toBe(0.95);
		expect(resolved.needsClarification).toBe(false);
	});

	it("buildMissionBrief ranks top-K evidence refs with explicit file/check refs", () => {
		const brief = buildMissionBrief({
			workingState: {
				changed_areas: {
					paths: ["src/memory/brief.ts", "src/review.ts", "tests/memory/brief.test.ts"],
				},
				last_checks: {
					failing: [
						{ name: "bun test tests/memory", files: ["src/memory/brief.ts", "tests/memory/brief.test.ts"] },
						{ name: "bun run typecheck", files: ["src/review.ts"] },
					],
					passing: [],
				},
				open_risks: [
					{
						type: "logic_regression",
						impact: 0.9,
						confidence: 0.9,
						evidence: ["src/memory/brief.ts", "tests/memory/brief.test.ts"],
						nextStep: "Add assertions",
					},
				],
			},
			maxEvidenceRefs: 5,
		});

		expect(brief.evidenceRefs).toHaveLength(5);
		expect(brief.evidenceRefs.some((ref) => ref.startsWith("check:"))).toBe(true);
		expect(brief.evidenceRefs).toContain("src/memory/brief.ts");
		expect(brief.markdown).toContain("Evidence refs (top-K):");
		expect(brief.markdown).toContain("- files:");
		expect(brief.markdown).toContain("- checks:");
		expect(brief.markdown).toContain("bun test tests/memory");
	});

	it("buildMissionBrief enforces truncation and keeps prompt bounded", () => {
		const brief = buildMissionBrief({
			workingState: {
				active_focus: {
					label: "Memory v0 milestone testing",
					source: "focus.override.manual",
					locked: true,
				},
				changed_areas: {
					paths: Array.from({ length: 1200 }, (_, i) => `src/module-${i}.ts`),
				},
				last_checks: {
					failing: [{ name: "bun test tests/memory", files: ["src/memory/brief.ts"] }],
					passing: [],
				},
				open_risks: [
					{ type: "logic_regression", impact: 0.8, confidence: 0.9, evidence: ["src/memory/brief.ts"], nextStep: "Add reducer assertions" },
					{ type: "coverage_gap", impact: 0.7, confidence: 0.8, evidence: ["tests/memory"], nextStep: "Add integration tests" },
					{ type: "api_break", impact: 0.6, confidence: 0.7, evidence: ["src/review.ts"], nextStep: "Verify prompt contract" },
					{ type: "perf", impact: 0.5, confidence: 0.6, evidence: ["src/memory/store.ts"], nextStep: "Profile sqlite calls" },
				],
			},
		});

		expect(brief.markdown).toContain("## SASU Mission Brief");
		expect(brief.markdown.length <= 7200).toBe(true);
		expect((brief.estimatedTokens ?? 0) <= 1800).toBe(true);
		expect(brief.topRisks).toHaveLength(3);
		expect(brief.nextValidationStep).toContain("Run bun test tests/memory");
	});
});
