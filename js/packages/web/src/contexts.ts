import { createContext } from "@lit/context";

const ctx = <T>(key: string) => createContext<T>(Symbol(key));

import type {
  ThemeContext,
  OperationContext,
  ModeContext,
  TabContext,
  QueryContext,
  SearchContext,
  AskContext,
} from "./types";

export const themeContext = ctx<ThemeContext>("theme");
export const operationContext = ctx<OperationContext>("operation");
export const modeContext = ctx<ModeContext>("mode");
export const queryContext = ctx<QueryContext>("query");
export const searchContext = ctx<SearchContext>("search");
export const askContext = ctx<AskContext>("ask");
export const tabContext = ctx<TabContext>("tabs");
