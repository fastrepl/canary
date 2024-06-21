import { describe, it, expect, vi } from "vitest";

import { setupServer } from "msw/node";
import { sseHandler } from "./mock";

import CanaryClient, { Response } from "./main";

const BASE_URL = "http://example.com";

describe("CanaryClient", () => {
  it("properly handles a SSE response", async () => {
    const handleResponse = vi.fn();
    const client = new CanaryClient(BASE_URL, handleResponse);

    const response: Response[] = [
      { id: "1", content: "hello" },
      { id: "1", content: " !", done: true },
    ];

    const server = setupServer(sseHandler(client.url, response));
    server.listen();

    await client.submit("1", "hi!");
    expect(handleResponse).toBeCalledWith(response[0]);
    expect(handleResponse).toBeCalledWith(response[1]);

    server.close();
  });
});
