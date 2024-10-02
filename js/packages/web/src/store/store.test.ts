import { test, expect, vi, beforeAll, afterAll, afterEach } from "vitest";

import { setupServer } from "msw/node";
import { searchHandler, askHandler } from "../msw";

import { asyncSleep } from "../utils";
import { SearchFunction, AskFunction, SearchResult } from "../types";
import { MODE_SEARCH, MODE_ASK } from "../constants";

import { createStore } from "./store";
import { TaskStatus } from "./managers";

const handlers = [searchHandler, askHandler];
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("debounced search", async () => {
  const store = createStore(document.createElement("div"));

  const matches: SearchResult[] = [
    {
      type: "webpage",
      meta: {},
      url: "https://example.com",
      title: "Hello",
      excerpt: "Hello",
      sub_results: [
        {
          url: "https://example.com",
          title: "Hello",
          excerpt: "Hello",
        },
      ],
    },
  ];
  const search = vi
    .fn()
    .mockImplementationOnce(
      async (
        _query: string,
        _signal: AbortSignal,
      ): ReturnType<SearchFunction> => {
        return { matches };
      },
    );

  store.send({ type: "register_operations", data: { search } });
  store.send({ type: "register_mode", data: MODE_SEARCH });

  store.send({ type: "set_query", data: { text: "tes" } });
  await asyncSleep(30);
  store.send({ type: "set_query", data: { text: "test" } });

  await vi.waitFor(
    () => {
      const ctx = store.getSnapshot().context.executionManager.ctx;
      if (ctx.status !== TaskStatus.COMPLETE) {
        throw new Error();
      }
    },
    { timeout: 2000, interval: 50 },
  );

  const snapshot = store.getSnapshot().context.executionManager.ctx;
  expect(search).toHaveBeenCalledTimes(1);
  expect(snapshot.status).toBe(TaskStatus.COMPLETE);
  expect(snapshot.search.matches).toEqual(matches);
});

test("ask", async () => {
  const store = createStore(document.createElement("div"));

  const ask = vi
    .fn()
    .mockImplementationOnce(
      async (_query: string, _signal: AbortSignal): ReturnType<AskFunction> => {
        return null;
      },
    );

  store.send({ type: "register_operations", data: { ask } });
  store.send({ type: "register_mode", data: MODE_SEARCH });
  store.send({ type: "register_mode", data: MODE_ASK });
});
