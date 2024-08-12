import { ContextProvider } from "@lit/context";

import { createStore as store } from "@xstate/store";

import type { OperationContext, AskContext } from "../types";
import { operationContext, modeContext, queryContext } from "../contexts";
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
          current: "",
        },
      }),
      query: new ContextProvider(host, {
        context: queryContext,
        initialValue: "",
      }),
      searchManager: new SearchManager(host, {
        debounceMs: 140,
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
          const options = context.mode.value.options.add(data);
          const current = context.mode.value.current || data;
          context.mode.setValue({ options, current });
          return context.mode;
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
          }
          if (data === MODE_ASK) {
            context.searchManager.abort();
            context.askManager.run(
              context.query.value,
              context.operation.value,
            );
          }

          return context.mode;
        },
      },
      set_query: {
        query: (context, { data }: { data: string }) => {
          context.query.setValue(data);

          if (context.mode.value.current === MODE_SEARCH) {
            context.searchManager.run(data, context.operation.value);
          }
          if (context.mode.value.current === MODE_ASK) {
            context.askManager.run(data, context.operation.value);
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
