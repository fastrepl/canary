import { test, expect, vi, beforeAll, afterAll, afterEach } from "vitest";

import { setupServer } from "msw/node";
import { searchHandler, askHandler } from "../msw";

import { asyncSleep } from "../utils";
import { SearchFunction, AskFunction } from "../types";
import { MODE_SEARCH, MODE_ASK, LOCAL_SOURCE } from "../constants";

import { createStore } from "./store";
import { TaskStatus } from "./managers";

const handlers = [searchHandler, askHandler];
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("debounced search", async () => {
  const store = createStore(document.createElement("div"));

  const data = [
    {
      url: "https://example.com",
      title: "Hello",
    },
  ];
  const search = vi
    .fn()
    .mockImplementationOnce(
      async (
        _query: string,
        _signal: AbortSignal,
      ): ReturnType<SearchFunction> => {
        return { references: { [LOCAL_SOURCE]: data } };
      },
    );

  store.send({ type: "register_operations", data: { search } });
  store.send({ type: "register_mode", data: MODE_SEARCH });

  store.send({ type: "set_query", data: "tes" });
  await asyncSleep(30);
  store.send({ type: "set_query", data: "test" });

  await vi.waitFor(
    () => {
      const ctx = store.getSnapshot().context.searchManager.ctx;
      if (ctx.status !== TaskStatus.COMPLETE) {
        throw new Error();
      }
    },
    { timeout: 2000, interval: 50 },
  );

  const snapshot = store.getSnapshot().context.searchManager.ctx;
  expect(search).toHaveBeenCalledTimes(1);
  expect(snapshot.status).toBe(TaskStatus.COMPLETE);
  expect(snapshot.result.references[LOCAL_SOURCE]).toEqual(data);
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
