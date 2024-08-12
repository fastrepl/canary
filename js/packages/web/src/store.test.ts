import {
  describe,
  test,
  expect,
  vi,
  beforeAll,
  afterAll,
  afterEach,
} from "vitest";

import { setupServer } from "msw/node";
import { searchHandler, askHandler, suggestHandler } from "./msw";

import { createStore } from "./store";
import { SearchFunction } from "./types";
import { asyncSleep } from "./utils";

const handlers = [searchHandler, askHandler, suggestHandler];
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("store", async () => {
  expect(true).toBe(true);
  const store = createStore(document.createElement("div"));

  const search = vi
    .fn()
    .mockImplementation(
      async (
        _query: string,
        _signal: AbortSignal,
      ): ReturnType<SearchFunction> => {
        return [];
      },
    );

  store.send({ type: "register_operations", data: { search } });

  store.send({ type: "set_query", data: "tes" });
  await asyncSleep(100);
  store.send({ type: "set_query", data: "test" });
});
