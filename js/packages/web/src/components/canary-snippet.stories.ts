import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-snippet";

export default {
  title: "Public/canary-snippet",
  parameters: { sourceLink: "components/canary-snippet.stories.ts" },
  render: ({ text }: any) => {
    return html`
      <div style="width: 400px; border: 1px solid black">
        <canary-snippet .value=${text}></canary-snippet>
      </div>
    `;
  },
} satisfies Meta;

export const Short: StoryObj = { args: { text: "<mark>123</mark> 123" } };
export const Long: StoryObj = {
  args: {
    text: "123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 123 <mark>123</mark> 123 123",
  },
};
