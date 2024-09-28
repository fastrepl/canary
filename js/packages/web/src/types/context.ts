import type {
  SearchResult,
  SearchFunction,
  BeforeSearchFunction,
  SearchFunctionResult,
} from "./search";
import type { AskFunction } from "./ask";
import type { FeedbackFunction } from "./feedback";
import { TaskStatus } from "../store/managers";
import { AskResponse } from "./schema";

export type QueryContext = string;

export type ModeContext = {
  options: Set<string>;
  default: string | null;
  current: string | null;
};

export type ExecutionContext = {
  status: TaskStatus;
  ask: AskResponse;
  search: SearchFunctionResult;
  _search: SearchFunctionResult;
};

export type FiltersContext = {
  [ID: string]: {
    fn: (matches: SearchResult[], args: any) => SearchResult[];
    args: any;
  };
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
