import type {
  SearchFunction,
  BeforeSearchFunction,
  SearchReference,
} from "./search";
import type { AskFunction } from "./ask";
import type { FeedbackFunction } from "./feedback";
import { TaskStatus } from "../constants";

export type QueryContext = string;

export type ModeContext = {
  options: Set<string>;
  current: string | null;
};

export type SearchContext = {
  status: TaskStatus;
  references: SearchReference[];
};

export type ThemeContext = "light" | "dark";

export type Framework = "starlight" | "docusaurus" | "vitepress";

export type TriggerShortcut = "cmdk" | "slash";

export type OperationContext = Partial<{
  search: SearchFunction;
  beforeSearch: BeforeSearchFunction;
  ask: AskFunction;
  feedback: FeedbackFunction;
}>;
