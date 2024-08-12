import { http, HttpResponse, delay } from "msw";

import type { SearchReference, AskReference } from "./types";

const MOCK_RESPONSE = `
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

const mockSearchReferences = (
  type: string,
  query: string,
): SearchReference[] => {
  const getN = (q: string) => {
    const match = q.match(/(\d+)(?!.*\d)/);
    return match ? parseInt(match[0], 10) : 0;
  };

  return Array(getN(query))
    .fill(null)
    .map(() => {
      const url =
        Math.random() > 0.5
          ? `https://example.com/a/b?query=${query}`
          : `https://example.com/api/b?query=${query}`;

      return {
        title: "title",
        titles: ["aaaa", "bbb"],
        url,
        excerpt: `<mark>${type}</mark> response: <mark>${query}</mark>!`,
      };
    });
};

const mockAskReference = (): AskReference => {
  return {
    title: "456",
    url: "https://example.com/a/b",
  };
};

export const searchHandler = http.post(
  /.*\/api\/v1\/search/,
  async ({ request }) => {
    const data = (await request.json()) as Record<string, string>;
    const query = data["query"];
    const items = mockSearchReferences("search", query);

    const isQuestion = query.trim().split(" ").length > 2;

    await delay(Math.random() * (isQuestion ? 1000 : 200) + 100);
    return HttpResponse.json(items);
  },
);

export const askHandler = http.post(/.*\/api\/v1\/ask/, async () => {
  await delay(Math.random() * 2000);

  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      const chunkSize = Math.floor(Math.random() * 3) + 3; // 3-5 characters
      let index = 0;

      while (index < MOCK_RESPONSE.length) {
        const chunk = MOCK_RESPONSE.slice(index, index + chunkSize);
        const data = `data: ${JSON.stringify({ type: "progress", content: chunk })}\n\n`;

        controller.enqueue(encoder.encode(data));
        index += chunkSize;

        await delay(Math.random() * 50 + 20);
      }

      const references = `data: ${JSON.stringify({ type: "references", items: [mockAskReference()] })}\n\n`;
      controller.enqueue(encoder.encode(references));
      controller.close();
    },
  });

  return new HttpResponse(stream, {
    headers: {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    },
  });
});
