import { createContext } from "@lit/context";

const ctx = <T>(key: string) => createContext<T>(Symbol(key));

import type {
  ModeContext,
  ThemeContext,
  QueryContext,
  OperationContext,
} from "./types";

export const modeContext = ctx<ModeContext>("mode");
export const queryContext = ctx<QueryContext>("query");
export const themeContext = ctx<ThemeContext>("theme");
export const operationContext = ctx<OperationContext>("operation");

export const defaultOperationContext: OperationContext = {
  search: (..._) => {
    console.error("'search' is not implemented");
    return Promise.resolve(null);
  },
  ask: (..._) => {
    console.error("'ask' is not implemented");
    return Promise.resolve(null);
  },
  feedback: (..._) => {
    console.error("'feedback' is not implemented");
    return Promise.resolve(null);
  },
};
