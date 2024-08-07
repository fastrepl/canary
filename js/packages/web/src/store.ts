import { ContextProvider } from "@lit/context";

import { createStore as store } from "@xstate/store";

import { type OperationContext } from "./types";
import { operationContext, modeContext, queryContext } from "./contexts";

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
          return context.mode;
        },
      },
      set_query: {
        query: (context, { data }: { data: string }) => {
          context.query.setValue(data);
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
