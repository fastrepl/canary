import { http, HttpResponse, delay } from "msw";

import type {
  SearchResult,
  SearchFunctionResult,
  AskResponse,
  QueryContext,
} from "./types";

export const mockAskResponse = JSON.stringify({
  scratchpad: "thinking",
  blocks: [
    {
      type: "reference",
      title: "title",
      url: "https://example.com/docs/a/b",
      sections: [
        {
          title: "title",
          url: "https://example.com/docs/a/b",
          excerpt: "this is a match.",
          explanation: "this is an explanation.",
        },
      ],
    },
    {
      type: "reference",
      title: "title",
      url: "https://example.com/docs/a/b",
      sections: [
        {
          title: "title",
          url: "https://example.com/docs/a/b",
          excerpt: "this is a match.",
          explanation: "this is an explanation.",
        },
        {
          title: "title",
          url: "https://example.com/docs/a/b",
          excerpt: "this is a match.",
          explanation: "this is an explanation.",
        },
        {
          title: "title",
          url: "https://example.com/docs/a/b",
          excerpt: "this is a match.",
          explanation: "this is an explanation.",
        },
      ],
    },
    {
      type: "text",
      text: "**Yes.**",
    },
  ],
} satisfies AskResponse);

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

      if (index % 3 === 1) {
        return {
          type: "github_issue",
          meta: {
            closed: Math.random() > 0.5,
          },
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
      }

      if (index % 3 === 2) {
        return {
          type: "github_discussion",
          meta: {
            closed: Math.random() > 0.5,
            answered: Math.random() > 0.5,
          },
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
      }

      return {
        type: "webpage",
        meta: {},
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

export const searchHandler = http.post(
  /.*\/api\/v1\/search/,
  async ({ request }) => {
    const data = (await request.json()) as Record<string, any>;
    const query = data["query"] as QueryContext;

    const isQuestion = query.text.trim().split(" ").length > 2;
    await delay(Math.random() * (isQuestion ? 1000 : 200) + 100);

    const result: SearchFunctionResult = {
      matches: mockSearchReferences("search", query.text),
      suggestion: {
        questions:
          query.text.startsWith("Can") || query.text.startsWith("What")
            ? [query.text]
            : [`Can you tell me about ${query}?`],
      },
    };
    return HttpResponse.json(result);
  },
);

export const askHandler = http.post(/.*\/api\/v1\/ask/, async () => {
  await delay(Math.random() * 1400);

  const encoder = new TextEncoder();
  const stream = new ReadableStream({
    async start(controller) {
      const chunkSize = Math.floor(Math.random() * 3) + 10; // 10 characters
      let index = 0;

      while (index < mockAskResponse.length) {
        const chunk = mockAskResponse.slice(index, index + chunkSize);
        const data = `data: ${chunk}\r\n\r\n`;

        controller.enqueue(encoder.encode(data));
        index += chunkSize;

        await delay(Math.random() * 50 + 20);
      }

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
