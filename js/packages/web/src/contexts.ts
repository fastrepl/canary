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
  search: (..._) => notImplemented("search"),
  ask: (..._) => notImplemented("ask"),
  feedback: (..._) => notImplemented("feedback"),
};

const notImplemented = (name: string) => {
  console.error(`'${name}' is not implemented`);
  return Promise.resolve(null);
};
