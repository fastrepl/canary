import { describe, test, expect, beforeAll, afterAll, afterEach } from "vitest";

import { setupServer } from "msw/node";
import { stripURL, urlToParts, sseIterator } from "./utils";

import { askHandler } from "./msw";

const handlers = [askHandler];
const server = setupServer(...handlers);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe("urlToParts", () => {
  test("with host", () => {
    expect(urlToParts("https://example.com/docs/ab-c/B_cd/d")).toEqual([
      "Docs",
      "Ab c",
      "B cd",
      "D",
    ]);
  });

  test("without host", () => {
    expect(urlToParts("/docs/abc/Bcd/d/e#a")).toEqual(["Abc", "Bcd", "D", "E"]);
  });
});

describe("stripURL", () => {
  test.each([
    ["https://example.com", "/"],
    ["https://example.com/docs/a/b", "/docs/a/b"],
    [
      "https://example.com/?name=Jonathan%20Smith&age=18",
      "/?name=Jonathan%20Smith&age=18",
    ],
    ["/", "/"],
    ["/docs/a/b", "/docs/a/b"],
    ["/?name=Jonathan%20Smith&age=18", "/?name=Jonathan%20Smith&age=18"],
  ])("%s", (input, expected) => {
    expect(stripURL(input)).toEqual(expected);
  });
});

describe("sse", () => {
  test("it works", async () => {
    const req = new Request("http://localhost/api/v1/ask", { method: "POST" });

    const receivedData = [];
    for await (const data of sseIterator(req)) {
      receivedData.push(data);
    }

    expect(receivedData.length).toBeGreaterThan(0);
  });
});
