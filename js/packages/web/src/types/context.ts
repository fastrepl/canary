import type { SearchFunction, BeforeSearchFunction } from "./search";
import type { AskFunction } from "./ask";
import type { FeedbackFunction } from "./feedback";

export type QueryContext = string;

export type ModeContext = {
  options: Set<string>;
  current: string | null;
};

export type ThemeContext = "light" | "dark";

export type Framework = "starlight" | "docusaurus" | "vitepress";

export type TriggerShortcut = "cmdk" | "slash";

export type OperationContext = Partial<{
  search: SearchFunction;
  beforeSearch: BeforeSearchFunction;
  ai_search: SearchFunction;
  ask: AskFunction;
  feedback: FeedbackFunction;
}>;
