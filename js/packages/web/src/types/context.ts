import type { SearchFunction } from "./search";
import type { AskFunction } from "./ask";
import type { FeedbackFunction } from "./feedback";

export type QueryContext = string;

export type ModeContext = {
  options: Set<Mode>;
  current: Mode;
};

export enum Mode {
  Search = "Search",
  Ask = "Ask",
}

export type ThemeContext = "light" | "dark";

export type Framework = "starlight" | "docusaurus" | "vitepress";

export type TriggerShortcut = "cmdk" | "slash";

export type OperationContext = {
  search: SearchFunction;
  ask: AskFunction;
  feedback: FeedbackFunction;
};
