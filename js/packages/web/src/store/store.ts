import { ContextProvider } from "@lit/context";
import { createStore as store } from "@xstate/store";

import type { FiltersContext, OperationContext, QueryContext } from "../types";
import {
  operationContext,
  modeContext,
  filtersContext,
  queryContext,
} from "../contexts";
import { ExecutionManager } from "./managers";
import { MODE_ASK, MODE_SEARCH } from "../constants";
import { applyFilters } from "../utils";

const randomID = () => {
  try {
    return crypto.randomUUID();
  } catch (e) {
    return Array(2)
      .fill(null)
      .map(() => Math.random().toString(36).substring(2, 15))
      .join("-");
  }
};
export const createStore = (host: HTMLElement) =>
  store(
    {
      session_id: randomID(),
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
      filters: new ContextProvider(host, {
        context: filtersContext,
        initialValue: {},
      }),
      query: new ContextProvider(host, {
        context: queryContext,
        initialValue: { text: "", tags: [] },
      }),
      executionManager: new ExecutionManager(host, {
        searchDebounceMs: 80,
        askDebounceMs: 300,
      }),
    },
    {
      register_operations: (
        context,
        { data }: { data: Partial<OperationContext> },
      ) => {
        context.operation.setValue({ ...context.operation.value, ...data });
        return {
          operation: context.operation,
        };
      },
      register_mode: (context, { data }: { data: string }) => {
        context.mode.setValue({
          options: context.mode.value.options.add(data),
          current: context.mode.value.current ?? data,
          default: context.mode.value.default ?? data,
        });

        return {
          mode: context.mode,
        };
      },
      set_filter: (
        context,
        {
          data,
        }: {
          data: { name: string; filter: Partial<FiltersContext[string]> };
        },
      ) => {
        const filters = context.filters.value;
        const execution = context.executionManager.ctx;

        const newFilters = {
          ...filters,
          [data.name]: { ...filters[data.name], ...data.filter },
        };

        const newSearch = {
          ...execution.search,
          matches: applyFilters(execution._search.matches, newFilters),
        };

        context.filters.setValue(newFilters);
        context.executionManager.ctx = {
          ...execution,
          search: newSearch,
        };

        return {
          filters: context.filters,
          executionManager: context.executionManager,
        };
      },
      set_mode: (context, { data }: { data: string }) => {
        context.mode.setValue({ ...context.mode.value, current: data });

        if (data === MODE_SEARCH) {
          context.executionManager.abort();
          context.executionManager.search(
            context.session_id,
            context.query.value,
            context.operation.value,
            context.filters.value,
          );
        }
        if (data === MODE_ASK) {
          context.executionManager.abort();
          context.executionManager.ask(
            context.session_id,
            context.query.value,
            context.operation.value,
            context.filters.value,
          );
        }

        return {
          mode: context.mode,
          session_id: randomID(),
        };
      },
      set_query: (context, { data }: { data: Partial<QueryContext> }) => {
        const nextQuery = { ...context.query.value, ...data };
        context.query.setValue(nextQuery, true);
        context.mode.setValue({ ...context.mode.value, current: MODE_SEARCH });

        context.executionManager.search(
          context.session_id,
          nextQuery,
          context.operation.value,
          context.filters.value,
        );

        return {
          query: context.query,
          mode: context.mode,
          session_id:
            nextQuery.text.length === 0 ? randomID() : context.session_id,
        };
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
