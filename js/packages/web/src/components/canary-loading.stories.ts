import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-loading-spinner";
import "./canary-loading-dots";

const meta = {
  title: "Public/canary-loading",
  parameters: { sourceLink: "components/canary-loading.stories.ts" },
  render: ({ kind }) => {
    if (kind === "spinner") {
      return html` <canary-loading-spinner></canary-loading-spinner> `;
    }
    if (kind === "dots") {
      return html` <canary-loading-dots></canary-loading-dots> `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: "spinner" | "dots" }>;

export default meta;
export const Spinner: StoryObj = { args: { kind: "spinner" } };
export const Dots: StoryObj = { args: { kind: "dots" } };
