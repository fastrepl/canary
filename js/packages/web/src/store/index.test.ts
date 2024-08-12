import { test, expect, vi, beforeAll, afterAll, afterEach } from "vitest";

import { setupServer } from "msw/node";
import { searchHandler, askHandler } from "../msw";

import { asyncSleep } from "../utils";
import { SearchFunction } from "../types";
import { MODE_SEARCH } from "../constants";

import { createStore } from "./index";
import { TaskStatus } from "./managers";

const handlers = [searchHandler, askHandler];
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("store", async () => {
  expect(true).toBe(true);
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
        return data;
      },
    );

  store.send({ type: "register_operations", data: { search } });
  store.send({ type: "register_mode", data: MODE_SEARCH });

  store.send({ type: "set_query", data: "tes" });
  await asyncSleep(100);
  store.send({ type: "set_query", data: "test" });

  await vi.waitFor(
    () => {
      const ctx = store.getSnapshot().context.searchManager.ctx.value;
      if (ctx.status !== TaskStatus.COMPLETE) {
        throw new Error();
      }
    },
    { timeout: 2000, interval: 50 },
  );

  const snapshot = store.getSnapshot().context.searchManager.ctx.value;
  expect(search).toHaveBeenCalledTimes(1);
  expect(snapshot.status).toBe(TaskStatus.COMPLETE);
  expect(snapshot.references).toEqual(data);
});
