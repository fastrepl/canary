import { http, HttpResponse, delay } from "msw";

import type { AskReference, SearchResult, SearchFunctionResult } from "./types";

const MOCK_RESPONSE = `
**Yes.**

Here's some references:

<canary-reference url="https://example.com/docs/a/b" title="title" excerpt="this is a match."></canary-reference>
<canary-reference url="https://example.com/docs/a/c" title="title" excerpt="this is a match."></canary-reference>

Please let me know if you have any questions.

Please let me know if you have any questions.

Please let me know if you have any questions.
`.trim();

const mockSearchReferences = (type: string, query: string): SearchResult[] => {
  const getN = (q: string) => {
    const match = q.match(/(\d+)(?!.*\d)/);
    return match ? parseInt(match[0], 10) : 0;
  };

  const randomNumber = (min: number, max: number) => {
    return Math.floor(Math.random() * (max - min + 1) + min);
  };

  return Array(getN(query))
    .fill(null)
    .map((_, index) => {
      const url =
        Math.random() > 0.5
          ? `https://example.com/a/b?query=${query}`
          : `https://example.com/api/b?query=${query}`;

      return {
        title: `title ${index}`,
        url,
        excerpt: `<mark>${type}</mark> response: <mark>${query}</mark>!`,
        sub_results: Array(randomNumber(1, 3))
          .fill(null)
          .map((_) => ({
            title: `sub title ${index}`,
            url: `https://example.com/a/b?query=${query}`,
            excerpt: `<mark>${type}</mark> response: <mark>${query}</mark>!`,
          })),
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

    const isQuestion = query.trim().split(" ").length > 2;
    await delay(Math.random() * (isQuestion ? 1000 : 200) + 100);

    const result: SearchFunctionResult = {
      sources: [
        {
          name: "Docs",
          type: "webpage",
          hits: mockSearchReferences("search", query),
        },
      ],
      suggestion: {
        questions:
          query.startsWith("Can") || query.startsWith("What")
            ? [query]
            : [`Can you tell me about ${query}?`],
      },
    };
    return HttpResponse.json(result);
  },
);

export const askHandler = http.post(/.*\/api\/v1\/ask/, async () => {
  await delay(Math.random() * 2000);

  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      const chunkSize = Math.floor(Math.random() * 3) + 10; // 10 characters
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

export const feedbackPageHandler = http.post(
  /.*\/api\/v1\/feedback\/page/,
  async () => {
    await delay(Math.random() * 200 + 400);
    return new HttpResponse(null, { status: 200 });
  },
);
