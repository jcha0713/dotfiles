import { spawn, spawnSync } from "node:child_process";
import * as path from "node:path";
import type { ConfigData, Nullable, OpenMode } from "./types";
import { shellEscape } from "./utils";

type OpenResult = {
	ok: boolean;
	message: string;
};

type UIContext = {
	custom?: <T>(render: (tui: any, theme: any, kb: any, done: (value?: T) => void) => any) => Promise<T | undefined>;
};

function resolveOpenMode(config: ConfigData): OpenMode {
	const envMode = process.env.PI_OPEN_FILE_MODE?.trim().toLowerCase();
	if (config.openMode === "foreground" || config.openMode === "background") return config.openMode;
	if (envMode === "foreground" || envMode === "background") return envMode;
	return "foreground";
}

function resolveOpenCommand(config: ConfigData): Nullable<string> {
	const fromConfig = config.openCommand?.trim();
	if (fromConfig) return fromConfig;

	const fromEnv = process.env.PI_OPEN_FILE_COMMAND?.trim();
	if (fromEnv) return fromEnv;

	const editor = (process.env.VISUAL || process.env.EDITOR || "vi").trim();
	if (!editor) return "vi {file}";
	return `${editor} {file}`;
}

function buildOpenCommand(filePath: string, cwd: string, config: ConfigData): Nullable<string> {
	const template = resolveOpenCommand(config);
	if (!template) return null;

	const mentionsFile = template.includes("{file}") || template.includes("{path}");
	let command = template
		.replaceAll("{file}", shellEscape(filePath))
		.replaceAll("{path}", shellEscape(filePath))
		.replaceAll("{cwd}", shellEscape(cwd));

	if (!mentionsFile) {
		command += ` ${shellEscape(filePath)}`;
	}
	return command;
}

function runOpenCommand(filePath: string, cwd: string, config: ConfigData): OpenResult {
	const shell = process.env.SHELL || "/bin/sh";
	const command = buildOpenCommand(filePath, cwd, config);
	if (!command) {
		return {
			ok: false,
			message: "No open command configured.",
		};
	}

	const mode = resolveOpenMode(config);
	if (mode === "background") {
		const child = spawn(shell, ["-lc", command], {
			stdio: "ignore",
			env: process.env,
			cwd,
			detached: true,
		});
		child.unref();
		return { ok: true, message: `Launched open command in background: ${filePath}` };
	}

	const result = spawnSync(shell, ["-lc", command], {
		stdio: "inherit",
		env: process.env,
		cwd,
	});

	if (result.error) {
		return {
			ok: false,
			message: `Failed to open file: ${result.error.message}`,
		};
	}

	if (typeof result.status === "number" && result.status !== 0) {
		return {
			ok: false,
			message: `Open command exited with status ${result.status}`,
		};
	}

	return { ok: true, message: `Opened: ${filePath}` };
}

export async function openFilePath(
	cwd: string,
	filePath: string,
	config: ConfigData,
	ui?: UIContext,
): Promise<OpenResult> {
	const resolvedPath = path.isAbsolute(filePath) ? filePath : path.join(cwd, filePath);
	const mode = resolveOpenMode(config);

	if (mode === "background") {
		return runOpenCommand(resolvedPath, cwd, config);
	}

	if (ui?.custom) {
		let openResult: OpenResult = { ok: false, message: "Open command did not run." };
		await ui.custom<void>((tui, _theme, _kb, done) => {
			tui.stop();
			process.stdout.write("\x1b[2J\x1b[H");
			openResult = runOpenCommand(resolvedPath, cwd, config);
			tui.start();
			tui.requestRender(true);
			done();
			return { render: () => [], invalidate: () => {} };
		});
		return openResult;
	}

	return runOpenCommand(resolvedPath, cwd, config);
}
