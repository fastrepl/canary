import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-media-query";

export default {
  title: "Public/canary-media-query",
  parameters: { sourceLink: "components/canary-media-query.stories.ts" },
  render: () => {
    return html`
      <canary-media-query query="(min-width: 50rem)">
        <div>Desktop</div>
        <div slot="fallback">Mobile</div>
      </canary-media-query>
    `;
  },
} satisfies Meta;

export const Desktop: StoryObj = {
  args: {},
};

export const Mobile: StoryObj = {
  args: {},
  parameters: {
    viewport: { defaultViewport: "mobile1", disable: false },
  },
};
