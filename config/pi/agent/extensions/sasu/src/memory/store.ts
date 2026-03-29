import { execFile } from "node:child_process";
import { mkdir } from "node:fs/promises";
import * as path from "node:path";
import { promisify } from "node:util";
import { SESSION_DIR } from "../constants";
import type {
  FeedbackRecord,
  MemoryEvent,
  MemoryEventQuery,
  WorkingStateByKey,
  WorkingStateKey,
} from "./types";

const execFileAsync = promisify(execFile);
const CONTEXT_DB_FILE = "context.db";

function toSqlLiteral(value: string | null | undefined): string {
  if (value == null) return "NULL";
  return `'${value.replace(/'/g, "''")}'`;
}

function toJsonSqlLiteral(value: unknown): string {
  return toSqlLiteral(JSON.stringify(value));
}

function parseEventRow(row: Record<string, unknown>): MemoryEvent {
  const payloadRaw = typeof row.payload_json === "string" ? row.payload_json : "{}";
  const payload = JSON.parse(payloadRaw) as Record<string, unknown>;
  const sessionId = typeof row.session_id === "string" ? row.session_id : undefined;
  const fingerprint = typeof row.fingerprint === "string" ? row.fingerprint : undefined;
  return {
    id: String(row.id ?? ""),
    ts: String(row.ts ?? ""),
    projectRoot: String(row.project_root ?? ""),
    sessionId,
    source: String(row.source ?? "sasu") as MemoryEvent["source"],
    kind: String(row.kind ?? "user.command.review") as MemoryEvent["kind"],
    payload,
    fingerprint,
  };
}

const INIT_SQL = `
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS events (
	id TEXT PRIMARY KEY,
	ts TEXT NOT NULL,
	project_root TEXT NOT NULL,
	session_id TEXT,
	source TEXT NOT NULL,
	kind TEXT NOT NULL,
	payload_json TEXT NOT NULL,
	fingerprint TEXT
);

CREATE TABLE IF NOT EXISTS working_state (
	key TEXT PRIMARY KEY,
	value_json TEXT NOT NULL,
	updated_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS episodes (
	id TEXT PRIMARY KEY,
	start_ts TEXT NOT NULL,
	end_ts TEXT,
	summary TEXT,
	intent_json TEXT,
	evidence_json TEXT,
	outcome_json TEXT
);

CREATE TABLE IF NOT EXISTS feedback (
	id TEXT PRIMARY KEY,
	ts TEXT NOT NULL,
	suggestion_id TEXT,
	action TEXT NOT NULL,
	context_json TEXT
);

CREATE INDEX IF NOT EXISTS idx_events_project_root_ts_desc ON events(project_root, ts DESC);
CREATE INDEX IF NOT EXISTS idx_events_kind_ts_desc ON events(kind, ts DESC);
CREATE INDEX IF NOT EXISTS idx_events_session_id_ts_desc ON events(session_id, ts DESC);
CREATE INDEX IF NOT EXISTS idx_events_project_fingerprint_ts_desc ON events(project_root, fingerprint, ts DESC);
`;

export function resolveMemoryDbPath(cwd: string): string {
  return path.join(cwd, SESSION_DIR, CONTEXT_DB_FILE);
}

type SqlRunOptions = {
  json?: boolean;
};

async function runSql(dbPath: string, sql: string, options: SqlRunOptions = {}): Promise<string> {
  const args: string[] = [];
  if (options.json) args.push("-json");
  args.push(dbPath, sql);
  const { stdout } = await execFileAsync("sqlite3", args, { maxBuffer: 5 * 1024 * 1024 });
  return stdout;
}

export class MemoryStore {
  private readonly dbPath: string;
  private initialized = false;

  constructor(cwd: string, dbPath?: string) {
    this.dbPath = dbPath ?? resolveMemoryDbPath(cwd);
  }

  getDbPath(): string {
    return this.dbPath;
  }

  async init(): Promise<void> {
    if (this.initialized) return;
    await mkdir(path.dirname(this.dbPath), { recursive: true });
    await runSql(this.dbPath, INIT_SQL);
    this.initialized = true;
  }

  private async ensureInit(): Promise<void> {
    if (!this.initialized) {
      await this.init();
    }
  }

  async appendEvent(event: MemoryEvent): Promise<void> {
    await this.ensureInit();
    const sql = `
INSERT OR IGNORE INTO events (
	id, ts, project_root, session_id, source, kind, payload_json, fingerprint
) VALUES (
	${toSqlLiteral(event.id)},
	${toSqlLiteral(event.ts)},
	${toSqlLiteral(event.projectRoot)},
	${toSqlLiteral(event.sessionId)},
	${toSqlLiteral(event.source)},
	${toSqlLiteral(event.kind)},
	${toJsonSqlLiteral(event.payload)},
	${toSqlLiteral(event.fingerprint)}
);
`;
    await runSql(this.dbPath, sql);
  }

  async appendEvents(events: MemoryEvent[]): Promise<void> {
    if (events.length === 0) return;
    await this.ensureInit();
    const values = events
      .map(
        (event) =>
          `(${toSqlLiteral(event.id)}, ${toSqlLiteral(event.ts)}, ${toSqlLiteral(event.projectRoot)}, ${toSqlLiteral(event.sessionId)}, ${toSqlLiteral(event.source)}, ${toSqlLiteral(event.kind)}, ${toJsonSqlLiteral(event.payload)}, ${toSqlLiteral(event.fingerprint)})`,
      )
      .join(",\n");
    const sql = `
BEGIN TRANSACTION;
INSERT OR IGNORE INTO events (id, ts, project_root, session_id, source, kind, payload_json, fingerprint)
VALUES
${values};
COMMIT;
`;
    await runSql(this.dbPath, sql);
  }

  async queryEvents(filters: MemoryEventQuery = {}): Promise<MemoryEvent[]> {
    await this.ensureInit();

    const where: string[] = [];
    if (filters.projectRoot) where.push(`project_root = ${toSqlLiteral(filters.projectRoot)}`);
    if (filters.sessionId) where.push(`session_id = ${toSqlLiteral(filters.sessionId)}`);
    if (filters.sinceTs) where.push(`ts >= ${toSqlLiteral(filters.sinceTs)}`);
    if (filters.untilTs) where.push(`ts <= ${toSqlLiteral(filters.untilTs)}`);
    if (filters.kinds && filters.kinds.length > 0) {
      const list = filters.kinds.map((kind) => toSqlLiteral(kind)).join(", ");
      where.push(`kind IN (${list})`);
    }

    const limit = Math.max(1, Math.min(filters.limit ?? 100, 5000));
    const offset = Math.max(filters.offset ?? 0, 0);
    const whereSql = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const sql = `
SELECT id, ts, project_root, session_id, source, kind, payload_json, fingerprint
FROM events
${whereSql}
ORDER BY ts DESC
LIMIT ${limit} OFFSET ${offset};
`;

    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return [];
    const rows = JSON.parse(stdout) as Array<Record<string, unknown>>;
    return rows.map(parseEventRow);
  }

  async findRecentEventByFingerprint(input: {
    projectRoot: string;
    fingerprint?: string;
    sessionId?: string;
    sinceTs?: string;
    untilTs?: string;
  }): Promise<MemoryEvent | null> {
    await this.ensureInit();
    if (!input.fingerprint || input.fingerprint.trim().length === 0) return null;

    const where: string[] = [
      `project_root = ${toSqlLiteral(input.projectRoot)}`,
      `fingerprint = ${toSqlLiteral(input.fingerprint)}`,
    ];
    if (input.sessionId && input.sessionId.trim().length > 0) {
      where.push(`session_id = ${toSqlLiteral(input.sessionId)}`);
    } else {
      where.push("session_id IS NULL");
    }
    if (input.sinceTs && input.sinceTs.trim().length > 0) {
      where.push(`ts >= ${toSqlLiteral(input.sinceTs)}`);
    }
    if (input.untilTs && input.untilTs.trim().length > 0) {
      where.push(`ts <= ${toSqlLiteral(input.untilTs)}`);
    }

    const sql = `
SELECT id, ts, project_root, session_id, source, kind, payload_json, fingerprint
FROM events
WHERE ${where.join(" AND ")}
ORDER BY ts DESC
LIMIT 1;
`;
    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return null;
    const rows = JSON.parse(stdout) as Array<Record<string, unknown>>;
    const row = rows[0];
    if (!row) return null;
    return parseEventRow(row);
  }

  async getEventTotalCount(
    filters: { projectRoot?: string; sessionId?: string } = {},
  ): Promise<number> {
    await this.ensureInit();
    const where: string[] = [];
    if (filters.projectRoot) where.push(`project_root = ${toSqlLiteral(filters.projectRoot)}`);
    if (filters.sessionId) where.push(`session_id = ${toSqlLiteral(filters.sessionId)}`);
    const whereSql = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const sql = `
SELECT COUNT(1) AS total
FROM events
${whereSql};
`;
    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return 0;
    const rows = JSON.parse(stdout) as Array<{ total?: number | string }>;
    const total = rows[0]?.total;
    if (typeof total === "number") return total;
    if (typeof total === "string") return Number(total) || 0;
    return 0;
  }

  async getEventCountsByKind(
    filters: { projectRoot?: string; sessionId?: string } = {},
  ): Promise<Record<string, number>> {
    await this.ensureInit();
    const where: string[] = [];
    if (filters.projectRoot) where.push(`project_root = ${toSqlLiteral(filters.projectRoot)}`);
    if (filters.sessionId) where.push(`session_id = ${toSqlLiteral(filters.sessionId)}`);
    const whereSql = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";
    const sql = `
SELECT kind, COUNT(1) AS total
FROM events
${whereSql}
GROUP BY kind
ORDER BY kind ASC;
`;
    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return {};
    const rows = JSON.parse(stdout) as Array<{ kind?: string; total?: number | string }>;
    const counts: Record<string, number> = {};
    for (const row of rows) {
      if (typeof row.kind !== "string") continue;
      if (typeof row.total === "number") {
        counts[row.kind] = row.total;
        continue;
      }
      if (typeof row.total === "string") {
        counts[row.kind] = Number(row.total) || 0;
      }
    }
    return counts;
  }

  async upsertWorkingState<K extends WorkingStateKey>(
    key: K,
    value: WorkingStateByKey[K],
  ): Promise<void> {
    await this.ensureInit();
    const now = new Date().toISOString();
    const sql = `
INSERT INTO working_state (key, value_json, updated_at)
VALUES (${toSqlLiteral(key)}, ${toJsonSqlLiteral(value)}, ${toSqlLiteral(now)})
ON CONFLICT(key) DO UPDATE SET
	value_json = excluded.value_json,
	updated_at = excluded.updated_at;
`;
    await runSql(this.dbPath, sql);
  }

  async getWorkingState<K extends WorkingStateKey>(key: K): Promise<WorkingStateByKey[K] | null> {
    await this.ensureInit();
    const sql = `
SELECT value_json
FROM working_state
WHERE key = ${toSqlLiteral(key)}
LIMIT 1;
`;
    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return null;
    const rows = JSON.parse(stdout) as Array<{ value_json?: string }>;
    const valueRaw = rows[0]?.value_json;
    if (typeof valueRaw !== "string") return null;
    return JSON.parse(valueRaw) as WorkingStateByKey[K];
  }

  async getWorkingStateSnapshot(): Promise<Partial<WorkingStateByKey>> {
    await this.ensureInit();
    const sql = `
SELECT key, value_json
FROM working_state
ORDER BY key ASC;
`;
    const stdout = await runSql(this.dbPath, sql, { json: true });
    if (!stdout.trim()) return {};
    const rows = JSON.parse(stdout) as Array<{ key?: string; value_json?: string }>;
    const snapshot: Partial<WorkingStateByKey> = {};
    for (const row of rows) {
      if (typeof row.key !== "string" || typeof row.value_json !== "string") continue;
      (snapshot as Record<string, unknown>)[row.key] = JSON.parse(row.value_json);
    }
    return snapshot;
  }

  async appendFeedback(record: FeedbackRecord): Promise<void> {
    await this.ensureInit();
    const sql = `
INSERT OR REPLACE INTO feedback (id, ts, suggestion_id, action, context_json)
VALUES (
	${toSqlLiteral(record.id)},
	${toSqlLiteral(record.ts)},
	${toSqlLiteral(record.suggestionId)},
	${toSqlLiteral(record.action)},
	${toJsonSqlLiteral(record.context ?? {})}
);
`;
    await runSql(this.dbPath, sql);
  }

  async resetAll(): Promise<void> {
    await this.ensureInit();
    const sql = `
BEGIN TRANSACTION;
DELETE FROM events;
DELETE FROM working_state;
DELETE FROM episodes;
DELETE FROM feedback;
COMMIT;
`;
    await runSql(this.dbPath, sql);
  }
}

export async function createMemoryStore(cwd: string): Promise<MemoryStore> {
  const store = new MemoryStore(cwd);
  await store.init();
  return store;
}
