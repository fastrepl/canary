import { ContextProvider } from "@lit/context";

import { createStore as store } from "@xstate/store";

import type { OperationContext, AskContext, TabDefinitions } from "../types";
import {
  operationContext,
  modeContext,
  queryContext,
  tabContext,
} from "../contexts";
import { SearchManager, AskManager } from "./managers";
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
      searchManager: new SearchManager(host, {
        debounceMs: 100,
      }),
      askManager: new AskManager(host),
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

          if (data === MODE_SEARCH) {
            context.askManager.abort();
            context.searchManager.run(
              context.query.value,
              context.operation.value,
            );
          } else if (data === MODE_ASK) {
            context.searchManager.abort();

            const tab = context.tab.value;
            const pattern = tab.options?.[tab.current]?.pattern;

            context.askManager.run(
              context.query.value,
              pattern,
              context.operation.value,
            );
          } else {
            context.searchManager.abort();
            context.askManager.abort();
          }

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
          context.query.setValue(data);

          if (context.mode.value.current === MODE_SEARCH) {
            context.searchManager.run(data, context.operation.value);
          }
          if (context.mode.value.current === MODE_ASK) {
            const tab = context.tab.value;
            const pattern = tab.options?.[tab.current]?.pattern;

            context.askManager.run(data, pattern, context.operation.value);
          }

          return context.query;
        },
      },
      _unsafe_set_ask_ctx: {
        askManager: (context, { data }: { data: Partial<AskContext> }) => {
          context.askManager.ctx = { ...context.askManager.ctx, ...data };
          return context.askManager;
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
