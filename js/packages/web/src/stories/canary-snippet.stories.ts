import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "../components/canary-snippet-excerpt";

export default {
  title: "private-components/canary-snippet",
  parameters: { sourceLink: "components/canary-snippet.stories.ts" },
  render: ({ text }: any) => {
    return html`
      <div style="width: 400px; border: 1px solid black">
        <canary-snippet-excerpt .value=${text}></canary-snippet-excerpt>
      </div>
    `;
  },
} satisfies Meta;

export const ShortExcerpt: StoryObj = {
  args: {
    text: "<canary-snippet-excerpt>123</canary-snippet-excerpt> 123 <mark>123</mark>",
  },
};

export const LongExcerpt: StoryObj = {
  args: {
    text: "123 <h2>123</h2> 123 123 123 123 123 123 123 123 123 123 123 123 123 123 <mark>123</mark> 123 123",
  },
};
