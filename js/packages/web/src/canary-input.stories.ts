import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-input";

const render = ({ type }: any) => {
  if (type === "ask") {
    return html` <canary-input-ask></canary-input-ask> `;
  }

  return html` <canary-input-search></canary-input-search> `;
};

export default {
  render,
  title: "Public/canary-input",
  parameters: {
    sourceLink: "canary-input.stories.ts",
  },
} satisfies Meta;

export const Search: StoryObj = { args: { type: "search" } };
export const Ask: StoryObj = { args: { type: "ask" } };
