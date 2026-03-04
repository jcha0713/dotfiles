import { existsSync } from "node:fs";
import { isAbsolute, resolve } from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

type Launcher = {
	name: string;
	command: string;
	args: (target: string) => string[];
};

const CLI_LAUNCHERS: Launcher[] = [
	{ name: "VS Code", command: "code", args: (target) => [target] },
	{ name: "Cursor", command: "cursor", args: (target) => [target] },
	{ name: "Windsurf", command: "windsurf", args: (target) => [target] },
	{ name: "Zed", command: "zed", args: (target) => [target] },
	{ name: "Sublime Text", command: "subl", args: (target) => [target] },
	{ name: "IntelliJ IDEA", command: "idea", args: (target) => [target] },
];

const MAC_APP_LAUNCHERS: Launcher[] = [
	{ name: "Visual Studio Code (app)", command: "open", args: (target) => ["-a", "Visual Studio Code", target] },
	{ name: "Cursor (app)", command: "open", args: (target) => ["-a", "Cursor", target] },
	{ name: "Zed (app)", command: "open", args: (target) => ["-a", "Zed", target] },
	{ name: "Sublime Text (app)", command: "open", args: (target) => ["-a", "Sublime Text", target] },
	{ name: "IntelliJ IDEA (app)", command: "open", args: (target) => ["-a", "IntelliJ IDEA", target] },
];

function parseCommandSpec(spec: string): { command: string; args: string[] } | null {
	const parts = spec.match(/(?:[^\s"']+|"[^"]*"|'[^']*')+/g);
	if (!parts || parts.length === 0) return null;

	const unquote = (token: string) => {
		if (
			(token.startsWith('"') && token.endsWith('"') && token.length >= 2) ||
			(token.startsWith("'") && token.endsWith("'") && token.length >= 2)
		) {
			return token.slice(1, -1);
		}
		return token;
	};

	const [commandToken, ...argTokens] = parts;
	const command = unquote(commandToken ?? "").trim();
	if (!command) return null;

	return {
		command,
		args: argTokens.map((token) => unquote(token).trim()).filter((token) => token.length > 0),
	};
}

function launcherFromEnv(varName: "PI_OPEN_EDITOR_CMD" | "VISUAL" | "EDITOR"): Launcher | null {
	const raw = process.env[varName]?.trim();
	if (!raw) return null;

	const parsed = parseCommandSpec(raw);
	if (!parsed) return null;

	return {
		name: `${varName} (${raw})`,
		command: parsed.command,
		args: (target) => [...parsed.args, target],
	};
}

async function commandExists(pi: ExtensionAPI, command: string, cwd: string): Promise<boolean> {
	if (command.includes("/") || command.includes("\\")) return existsSync(command);
	const lookupCommand = process.platform === "win32" ? "where" : "which";
	try {
		const result = await pi.exec(lookupCommand, [command], { cwd, timeout: 2_000 });
		return result.code === 0;
	} catch {
		return false;
	}
}

function expandHome(pathInput: string): string {
	const home = process.env.HOME ?? process.env.USERPROFILE;
	if (!home) return pathInput;
	if (pathInput === "~") return home;
	if (pathInput.startsWith("~/") || pathInput.startsWith("~\\")) {
		return resolve(home, pathInput.slice(2));
	}
	return pathInput;
}

function parseTarget(args: string, cwd: string): string {
	let input = args.trim();
	if (input.length === 0) return cwd;

	if (
		(input.startsWith('"') && input.endsWith('"') && input.length >= 2) ||
		(input.startsWith("'") && input.endsWith("'") && input.length >= 2)
	) {
		input = input.slice(1, -1);
	}

	const expanded = expandHome(input);
	return isAbsolute(expanded) ? expanded : resolve(cwd, expanded);
}

function getLaunchers(): Launcher[] {
	const launchers: Launcher[] = [];

	const custom = launcherFromEnv("PI_OPEN_EDITOR_CMD");
	if (custom) launchers.push(custom);

	const visual = launcherFromEnv("VISUAL");
	if (visual) launchers.push(visual);

	const editor = launcherFromEnv("EDITOR");
	const visualRaw = process.env.VISUAL?.trim();
	const editorRaw = process.env.EDITOR?.trim();
	if (editor && editorRaw && editorRaw !== visualRaw) launchers.push(editor);

	launchers.push(...CLI_LAUNCHERS);
	if (process.platform === "darwin") {
		launchers.push(...MAC_APP_LAUNCHERS);
	}
	return launchers;
}

async function launch(
	pi: ExtensionAPI,
	launcher: Launcher,
	target: string,
	cwd: string,
): Promise<{ ok: true } | { ok: false; reason: string }> {
	try {
		const result = await pi.exec(launcher.command, launcher.args(target), { cwd, timeout: 10_000 });
		if (result.code === 0) return { ok: true };
		const reason = result.stderr.trim() || result.stdout.trim() || `exit code ${result.code}`;
		return { ok: false, reason };
	} catch (error) {
		const reason = error instanceof Error ? error.message : String(error);
		return { ok: false, reason };
	}
}

async function openHere(pi: ExtensionAPI, ctx: ExtensionContext, args: string): Promise<void> {
	const trimmed = args.trim().toLowerCase();
	if (trimmed === "-h" || trimmed === "--help" || trimmed === "help" || trimmed === "?") {
		ctx.ui.notify("Usage: /open-here [path]", "info");
		return;
	}

	const target = parseTarget(args, ctx.cwd);
	if (args.trim().length > 0 && !existsSync(target)) {
		ctx.ui.notify(`Target does not exist yet: ${target} (trying anyway).`, "warning");
	}

	const launchers = getLaunchers();
	const attempted: string[] = [];
	const failures: string[] = [];

	for (const launcher of launchers) {
		if (!(await commandExists(pi, launcher.command, ctx.cwd))) continue;
		attempted.push(launcher.name);

		const result = await launch(pi, launcher, target, ctx.cwd);
		if (result.ok) {
			ctx.ui.notify(`Opened ${target} via ${launcher.name}.`, "info");
			return;
		}
		failures.push(`${launcher.name}: ${result.reason}`);
	}

	if (attempted.length === 0) {
		ctx.ui.notify(
			"No supported editor launcher found on PATH. Set $VISUAL/$EDITOR (or PI_OPEN_EDITOR_CMD) if needed.",
			"error",
		);
		return;
	}

	ctx.ui.notify(
		`Could not open editor for ${target}. Tried: ${attempted.join(", ")}\n${failures.slice(0, 2).join("\n")}`,
		"error",
	);
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("open-here", {
		description: "Open current directory (or a path) in external editor",
		handler: async (args, ctx) => {
			await openHere(pi, ctx, args);
		},
	});
}
