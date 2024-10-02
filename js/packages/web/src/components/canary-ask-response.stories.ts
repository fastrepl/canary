import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import type { AskResponse } from "../types";

import "./canary-ask-response";

enum Kind {
  Complete,
}

export default {
  title: "private-components/canary-ask-response",
  parameters: { sourceLink: "components/canary-ask-response.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Complete) {
      const response: AskResponse = {
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
            text: "and also take a look at this:",
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
            ],
          },
          {
            type: "text",
            text: "so this is the end.",
          },
        ],
      };

      return html`
        <div style="max-width: 600px; margin: auto">
          <canary-ask-response .response=${response}></canary-ask-response>
        </div>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Complete: StoryObj = {
  args: { kind: Kind.Complete },
};
