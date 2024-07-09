import type { MockHandler } from "vite-plugin-mock-server";

const mocks: MockHandler[] = [
  {
    pattern: "/api/v1/search",
    handle: (req, res) => {
      const items = Array(Math.round(Math.random() * 20)).fill({
        url: "https://example.com",
        excerpt: "123",
        meta: { title: "123" },
      });

      setTimeout(() => {
        res.setHeader("Content-Type", "application/json");
        res.end(JSON.stringify(items));
      }, Math.random() * 4000);
    },
  },
  {
    pattern: "/api/v1/ask",
    handle: (req, res) => {
      res.writeHead(200, {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        Connection: "keep-alive",
      });

      res.write("data: sse\n\n");
      res.end();
    },
  },
];

export default mocks;
