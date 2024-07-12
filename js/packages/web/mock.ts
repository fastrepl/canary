import type { MockHandler } from "vite-plugin-mock-server";

const mocks: MockHandler[] = [
  {
    pattern: "/api/v1/search",
    handle: (req, res) => {
      const items = Array(Math.round(Math.random() * 5 + 5)).fill({
        title: "123",
        url: "https://example.com",
        excerpt: "123",
      });

      setTimeout(
        () => {
          res.setHeader("Content-Type", "application/json");
          res.end(JSON.stringify(items));
        },
        Math.random() * 200 + 400,
      );
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

      const chunkSize = Math.floor(Math.random() * 3) + 3; // 3-5 characters
      let index = 0;

      const interval = setInterval(() => {
        if (index < RESPONSE.length) {
          const chunk = RESPONSE.slice(index, index + chunkSize);
          res.write(
            `data: ${JSON.stringify({ type: "progress", content: chunk })} \n\n`,
          );
          index += chunkSize;
        } else {
          clearInterval(interval);
          res.end();
        }
      }, Math.random() * 60);

      req.on("close", () => {
        clearInterval(interval);
        res.end();
      });
    },
  },
];

const RESPONSE = `
# The Whimsical World of Flibbertigibbets

## Introduction

In the land of Zorkle, flibbertigibbets roam free, spreading their peculiar brand of gobbledygook wherever they wander. 

\`\`\`python
def hello():
  print("hello")

hello()
\`\`\`

## Key Characteristics of Flibbertigibbets

1. **Appearance**
   - Resemble a cross between a turnip and a disco ball
   - Sport iridescent feathers made of crystallized bubblegum

2. **Behavior**
   - Communicate through interpretive dance and armpit noises
   - Have a peculiar fondness for wearing monocles on their elbows
`.trim();

export default mocks;
