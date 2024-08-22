import type {
  SearchFunction,
  BeforeSearchFunction,
  SearchFunctionResult,
} from "./search";
import type { AskFunction, AskReference } from "./ask";
import type { FeedbackFunction } from "./feedback";
import type { TabDefinitions } from "./schema";
import { TaskStatus } from "../store/managers";

export type QueryContext = string;

export type ModeContext = {
  options: Set<string>;
  default: string | null;
  current: string | null;
};

export type TabContext = {
  options: TabDefinitions;
  current: number;
};

export type SearchContext = {
  status: TaskStatus;
  result: SearchFunctionResult;
};

export type AskContext = {
  status: TaskStatus;
  query: string;
  progress: boolean;
  response: string;
  references: AskReference[];
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
