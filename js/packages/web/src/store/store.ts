import { ContextProvider } from "@lit/context";

import { createStore as store } from "@xstate/store";

import type { OperationContext, TabDefinitions } from "../types";
import {
  operationContext,
  modeContext,
  queryContext,
  tabContext,
} from "../contexts";
import { ExecutionManager } from "./managers";
import { MODE_ASK, MODE_SEARCH } from "../constants";

export const createStore = (host: HTMLElement) =>
  store(
    {
      operation: new ContextProvider(host, {
        context: operationContext,
        initialValue: {},
      }),
      mode: new ContextProvider(host, {
        context: modeContext,
        initialValue: {
          options: new Set([]),
          default: null,
          current: null,
        },
      }),
      tab: new ContextProvider(host, {
        context: tabContext,
        initialValue: {
          options: [],
          current: 0,
        },
      }),
      query: new ContextProvider(host, {
        context: queryContext,
        initialValue: "",
      }),
      executionManager: new ExecutionManager(host, {
        searchDebounceMs: 150,
        askDebounceMs: 500,
      }),
    },
    {
      register_operations: {
        operation: (context, { data }: { data: Partial<OperationContext> }) => {
          context.operation.setValue({ ...context.operation.value, ...data });
          return context.operation;
        },
      },
      register_mode: {
        mode: (context, { data }: { data: string }) => {
          context.mode.setValue({
            options: context.mode.value.options.add(data),
            current: context.mode.value.current ?? data,
            default: context.mode.value.default ?? data,
          });

          return context.mode;
        },
      },
      register_tab: {
        tab: (context, { data }: { data: TabDefinitions }) => {
          context.tab.setValue({ options: data, current: 0 });
          return context.tab;
        },
      },
      set_mode: {
        mode: (context, { data }: { data: string }) => {
          context.mode.setValue({ ...context.mode.value, current: data });
          return context.mode;
        },
      },
      set_tab: {
        tab: (context, { data }: { data: number }) => {
          context.tab.setValue({ ...context.tab.value, current: data });
          return context.tab;
        },
      },
      set_query: {
        query: (context, { data }: { data: string }) => {
          context.query.setValue(data, true);

          const next =
            context.mode.value.options.has(MODE_ASK) &&
            data
              .split(" ")
              .map((s) => s.trim())
              .filter(Boolean).length > 2
              ? MODE_ASK
              : MODE_SEARCH;

          context.mode.setValue({ ...context.mode.value, current: next });

          if (next === MODE_SEARCH) {
            context.executionManager.search(data, context.operation.value);
          }
          if (next === MODE_ASK) {
            context.executionManager.ask(data, context.operation.value);
          }

          return context.query;
        },
      },
    },
  );

export const EVENT_NAME = "canary-broadcast";

export type Event = Parameters<ReturnType<typeof createStore>["send"]>[0];

export const createEvent = (event: Event) => {
  return new CustomEvent<Event>(EVENT_NAME, {
    detail: event,
    composed: true,
    bubbles: true,
  });
};

declare global {
  interface HTMLElementEventMap {
    [EVENT_NAME]: CustomEvent<Event>;
  }
}
