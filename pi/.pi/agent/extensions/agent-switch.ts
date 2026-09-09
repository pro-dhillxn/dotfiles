/**
 * Agent Switch — plan/build stage switching
 *
 * Stage agents are loaded from:
 *   ~/.pi/agent/agents/<name>.md
 *
 * Commands:
 *   /plan          activate the read-only planning agent
 *   /build         activate the implementation agent
 *   /agent         show the current agent
 *   /agent <name>  activate a named agent
 *   /agent none    return to the default agent
 *
 * The active agent is persisted as an `active_agent` session entry.
 *
 * Fresh sessions start in the `plan` (read-only) stage by default.
 * Run `/build` to start implementing, or `/agent none` to return to
 * the global permission policy.
 *
 * IMPORTANT:
 * There is intentionally NO `agent_switch` LLM tool.
 *
 * Agents cannot switch stages themselves. They must ask the user to run
 * `/plan` or `/build`. This is important because the permission system
 * resolves per-agent permissions when a new agent turn starts.
 */

import { existsSync, readdirSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type {
	ExtensionAPI,
	ExtensionUIContext,
} from "@earendil-works/pi-coding-agent";

const ACTIVE_AGENT_CUSTOM_TYPE = "active_agent";

// Fresh sessions (no persisted active_agent entry) start in the
// read-only planning stage. /build and /agent none escape it.
const DEFAULT_AGENT_NAME = "plan";

type ActiveAgentData = {
	name: string | null;
};

type AgentDoc = {
	name: string;
	description: string;
	body: string;
};

type NotifyFn = (
	message: string,
	type?: "info" | "warning" | "error",
) => void;

type UI = Pick<ExtensionUIContext, "notify" | "setStatus">;

export default function agentSwitchExtension(pi: ExtensionAPI) {
	let activeAgent: string | null = null;

	const agentsDir = join(getAgentDir(), "agents");

	function listAgents(): string[] {
		try {
			return readdirSync(agentsDir)
				.filter((file) => file.endsWith(".md"))
				.map((file) => file.replace(/\.md$/, ""))
				.sort();
		} catch {
			return [];
		}
	}

	function loadAgent(name: string): AgentDoc | null {
		const path = join(agentsDir, `${name}.md`);

		if (!existsSync(path)) {
			return null;
		}

		try {
			const raw = readFileSync(path, "utf-8").replace(/\r\n/g, "\n");

			let description = "";
			let body = raw.trim();

			if (raw.startsWith("---\n")) {
				const end = raw.indexOf("\n---", 4);

				if (end !== -1) {
					const frontmatter = raw.slice(4, end);
					body = raw.slice(end + 5).trim();

					const descriptionLine = frontmatter
						.split("\n")
						.find((line) => line.startsWith("description:"));

					if (descriptionLine) {
						description = descriptionLine
							.slice("description:".length)
							.trim()
							.replace(/^["']|["']$/g, "");
					}
				}
			}

			return {
				name,
				description,
				body,
			};
		} catch {
			return null;
		}
	}

	function statusText(): string {
		if (!activeAgent) {
			return "agent: default";
		}

		const doc = loadAgent(activeAgent);

		return `agent: ${activeAgent}${
			doc?.description ? ` (${doc.description})` : ""
		}`;
	}

	function restoreFromSession(entries: readonly unknown[]): string | null {
		for (let i = entries.length - 1; i >= 0; i--) {
			const entry = entries[i] as {
				type?: string;
				customType?: string;
				data?: {
					name?: unknown;
				};
			};

			if (
				entry?.type !== "custom" ||
				entry.customType !== ACTIVE_AGENT_CUSTOM_TYPE
			) {
				continue;
			}

			const name = entry.data?.name;

			if (typeof name === "string" && name.length > 0) {
				return name;
			}

			if (name === null || name === undefined) {
				return null;
			}
		}

		return null;
	}

	function switchTo(
		agent: string | null,
		notify: NotifyFn,
		ui?: UI,
	): void {
		if (activeAgent === agent) {
			notify(
				agent
					? `Already using the '${agent}' agent.`
					: "Already using the default agent.",
				"info",
			);
			return;
		}

		if (agent) {
			const doc = loadAgent(agent);

			if (!doc) {
				notify(
					`Unknown agent '${agent}'. Available: ${
						listAgents().join(", ") || "(none)"
					}`,
					"error",
				);
				return;
			}

			/*
			 * This is the signal consumed by pi-permission-system.
			 *
			 * It recognizes custom session entries with:
			 *
			 *   customType: "active_agent"
			 *
			 * and resolves the agent's permission: frontmatter from
			 * ~/.pi/agent/agents/<agent>.md.
			 */
			pi.appendEntry<ActiveAgentData>(
				ACTIVE_AGENT_CUSTOM_TYPE,
				{ name: agent },
			);

			activeAgent = agent;

			notify(
				`Switched to ${agent} agent${
					doc.description ? ` — ${doc.description}` : ""
				}`,
				"info",
			);
		} else {
			pi.appendEntry<ActiveAgentData>(
				ACTIVE_AGENT_CUSTOM_TYPE,
				{ name: null },
			);

			activeAgent = null;

			notify(
				"Switched to default agent (standard prompts, global permission policy)",
				"info",
			);
		}

		ui?.setStatus("agent-switch", statusText());
	}

	function handleSwitch(
		requestedRaw: string,
		notify: NotifyFn,
		ui?: UI,
	): string {
		const requested = requestedRaw.trim().toLowerCase();

		if (!requested) {
			const available = listAgents();

			return (
				`Current agent: ${activeAgent ?? "default"}. ` +
				`Available: ${available.join(", ") || "(none)"}. ` +
				`Use /agent <name>, /agent none, /plan, or /build.`
			);
		}

		if (requested !== "none" && !loadAgent(requested)) {
			return (
				`Unknown agent '${requested}'. Available: ${
					listAgents().join(", ") || "(none)"
				}.`
			);
		}

		switchTo(
			requested === "none" ? null : requested,
			notify,
			ui,
		);

		return requested === "none"
			? "Switched to default agent."
			: `Switched to '${requested}' agent.`;
	}

	/*
	 * Deliberately no pi.registerTool("agent_switch", ...).
	 *
	 * Stage changes are user-controlled. An agent must not be able to
	 * switch its own permission boundary during a turn.
	 */

	pi.registerCommand("plan", {
		description: "Enter the plan stage (read-only architect agent)",

		handler: async (_args, ctx) => {
			switchTo(
				"plan",
				(message, type) => ctx.ui.notify(message, type),
				ctx.ui,
			);
		},
	});

	pi.registerCommand("build", {
		description: "Enter the build stage (full implementation agent)",

		handler: async (_args, ctx) => {
			switchTo(
				"build",
				(message, type) => ctx.ui.notify(message, type),
				ctx.ui,
			);
		},
	});

	pi.registerCommand("agent", {
		description:
			"Show current agent; '/agent <name>' or '/agent none' to switch",

		getArgumentCompletions: (prefix) =>
			["none", ...listAgents()]
				.map((name) => ({
					value: name,
					label: name,
				}))
				.filter((item) =>
					item.value.startsWith(prefix.toLowerCase()),
				),

		handler: async (args, ctx) => {
			const message = handleSwitch(
				args,
				(message, type) => ctx.ui.notify(message, type),
				ctx.ui,
			);

			ctx.ui.notify(message, "info");
		},
	});

	pi.on("session_start", (event, ctx) => {
		const entries = ctx.sessionManager.getEntries();

		const branch =
			(
				ctx.sessionManager as {
					getBranch?: () => readonly unknown[];
				}
			).getBranch?.() ?? entries;

		const hasAgentEntry = branch.some(
			(entry) =>
				(
					entry as {
						customType?: string;
					}
				)?.customType === ACTIVE_AGENT_CUSTOM_TYPE,
		);

		if (!hasAgentEntry) {
			// Fresh session: start in the default planning stage.
			// Persisting the entry lets pi-permission-system resolve the
			// agent's permission: frontmatter from the very first turn.
			activeAgent = DEFAULT_AGENT_NAME;
			pi.appendEntry<ActiveAgentData>(ACTIVE_AGENT_CUSTOM_TYPE, {
				name: DEFAULT_AGENT_NAME,
			});
		} else {
			// Resume: honor the last saved state (agent name or an
			// explicit `/agent none` reset).
			activeAgent = restoreFromSession(branch);
		}

		ctx.ui.setStatus(
			"agent-switch",
			statusText(),
		);
	});

	/*
	 * Add the active agent's instructions to the system prompt.
	 *
	 * The permission system independently resolves the same agent from
	 * the active_agent session entry and applies its permission:
	 * frontmatter.
	 *
	 * We therefore do NOT parse or enforce permission: here.
	 */
	pi.on("before_agent_start", (event) => {
		if (!activeAgent) {
			return {};
		}

		const doc = loadAgent(activeAgent);

		if (!doc) {
			return {};
		}

		const agentBlock =
			`\n\n<active_agent name="${activeAgent}"/>\n` +
			`## Active stage agent: ${activeAgent}\n` +
			`${doc.body}`;

		return {
			systemPrompt: `${event.systemPrompt}\n${agentBlock}`,
		};
	});
}
