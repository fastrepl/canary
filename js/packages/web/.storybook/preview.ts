import { type Preview } from "@storybook/web-components";
import { withThemeByDataAttribute } from "@storybook/addon-themes";
import { MINIMAL_VIEWPORTS } from "@storybook/addon-viewport";

import { html } from "lit";
import "../src/components/canary-root";

import { http, HttpResponse, delay } from "msw";
import { initialize, mswLoader } from "msw-storybook-addon";
initialize();

import "../src/stories.css";
import { MOCK_RESPONSE, mockAskReference, mockSearchReferences } from "./mock";

const preview: Preview = {
  loaders: [mswLoader],
  decorators: [
    (story) => html`<canary-root>${story()}</canary-root>`,
    withThemeByDataAttribute({
      themes: { light: "light", dark: "dark" },
      parentSelector: "html",
      defaultTheme: "light",
      attributeName: "data-theme",
    }),
  ],
  parameters: {
    sourceLinkPrefix:
      "https://github.com/fastrepl/canary/tree/main/js/packages/web/src/",
    viewport: {
      viewports: { ...MINIMAL_VIEWPORTS },
      disable: true,
    },
    cssprops: {
      "canary-color-primary-c": { value: "0.1" },
      "canary-color-primary-h": { value: "260" },
    },
    msw: {
      handlers: {
        search: [
          http.post("/api/v1/search/normal", async ({ request }) => {
            const data = (await request.json()) as Record<string, string>;
            const items = mockSearchReferences("search", data["query"]);

            await delay(Math.random() * 200 + 200);
            return HttpResponse.json(items);
          }),
        ],
        ai_search: [
          http.post("/api/v1/search/ai", async ({ request }) => {
            const data = (await request.json()) as Record<string, string>;
            const items = mockSearchReferences("ai_search", data["query"]);

            await delay(Math.random() * 500 + 1400);
            return HttpResponse.json(items);
          }),
        ],
        // TODO: if we support hybrid search, retrived docs already exists both in the server and the client
        ask: [
          http.post(/.*\/api\/v1\/ask/, async () => {
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
          }),
        ],
      },
    },
  },
};

export default preview;
