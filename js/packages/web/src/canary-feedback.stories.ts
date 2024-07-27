import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-feedback-text";

const render = (_: any) => {
  return html` <canary-feedback-text></canary-feedback-text> `;
};

export default {
  render,
  title: "Public/canary-feedback",
  parameters: {
    sourceLink: "canary-feedback.stories.ts",
  },
} satisfies Meta;

export const Text: StoryObj = { args: {} };
