import { type Preview } from "@storybook/web-components";
import { withThemeByClassName } from "@storybook/addon-themes";
import { MINIMAL_VIEWPORTS } from "@storybook/addon-viewport";

import { http, HttpResponse, delay } from "msw";
import { initialize, mswLoader } from "msw-storybook-addon";
initialize();

import "../src/stories.css";
import { MOCK_RESPONSE, mockAskReference, mockSearchReference } from "./mock";

const preview: Preview = {
  loaders: [mswLoader],
  decorators: [
    withThemeByClassName({
      defaultTheme: "starlight-ocean-light",
      themes: {
        "starlight-ocean-light": "starlight-ocean-light bg-gray-100",
        "starlight-ocean-dark": "starlight-ocean-dark bg-gray-900",
        "starlight-oxide-light": "starlight-oxide-light bg-gray-100",
        "starlight-oxide-dark": "starlight-oxide-dark bg-gray-900",
      },
    }),
    // withThemeByDataAttribute({
    //   themes: { light: "light", dark: "dark" },
    //   parentSelector: "html",
    //   defaultTheme: "dark",
    //   attributeName: "data-theme",
    // }),
  ],
  parameters: {
    sourceLinkPrefix:
      "https://github.com/fastrepl/canary/tree/main/js/packages/web/src/",
    viewport: {
      viewports: {
        ...MINIMAL_VIEWPORTS,
      },
    },
    msw: {
      handlers: {
        default: [
          http.post("/api/v1/search", async () => {
            const items = Array(Math.round(Math.random() * 5 + 5)).fill(
              mockSearchReference(),
            );

            await delay(Math.random() * 300 + 200);
            return HttpResponse.json(items);
          }),
          http.post("/api/v1/ask", async () => {
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
