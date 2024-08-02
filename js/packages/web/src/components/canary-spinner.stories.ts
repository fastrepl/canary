import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-spinner";

export default {
  title: "Public/canary-spinner",
  parameters: { sourceLink: "canary-spinner.stories.ts" },
  render: () => {
    return html` <canary-spinner></canary-spinner> `;
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
