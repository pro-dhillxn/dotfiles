/**
 * π — minimalist startup header
 *
 * Replaces pi's built-in startup header (logo + keybinding list) with a small
 * mathematical π symbol and a single line of the most useful hints.
 *
 * Purely cosmetic: rendered by the TUI harness only. Never sent to the model,
 * zero impact on context.
 */

import { VERSION } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, Theme } from "@earendil-works/pi-coding-agent";

// The π glyph: a flat bar with two thin legs, drawn with half-blocks.
const GLYPH = [
	"▄▄▄▄▄",
	"▐   ▌",
	"▐   ▌",
];
const INDENT = "   ";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.mode !== "tui") return;

		ctx.ui.setHeader((_tui, theme: Theme) => ({
			// Styles are computed fresh on every render, so live theme
			// switches (e.g. light/dark sync) apply without a restart.
			render(_width: number): string[] {
				const glyph = GLYPH.map((line) => INDENT + theme.fg("accent", line));
				const subtitle =
					theme.bold(theme.fg("accent", "π")) + theme.fg("dim", ` v${VERSION}`);
				const hints = theme.fg(
					"muted",
					"esc interrupt · ctrl+c clear · / commands · ! bash · ctrl+o more",
				);
				return [...glyph, subtitle, hints];
			},
			invalidate() {},
		}));
	});
}
