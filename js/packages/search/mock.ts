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
      }, Math.random() * 2500);
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

      const generateChunk = () => {
        const length = Math.random() < 0.5 ? 2 : 4;
        return Array(length)
          .fill(0)
          .map(() => String.fromCharCode(97 + Math.floor(Math.random() * 26)))
          .join("");
      };

      const size = Math.floor(Math.random() * 30) + 30;
      let index = 0;

      const interval = setInterval(() => {
        if (index < size) {
          const chunk = generateChunk();
          res.write(`data: ${chunk} \n\n`);
          index++;
        } else {
          clearInterval(interval);
          res.end();
        }
      }, Math.random() * 50);

      req.on("close", () => {
        clearInterval(interval);
        res.end();
      });
    },
  },
];

export default mocks;
