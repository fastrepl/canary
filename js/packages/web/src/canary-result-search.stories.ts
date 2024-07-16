import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-content";
import "./canary-callout-cal";
import "./canary-callout-discord";
import { type Reference } from "./core";

const items: Reference[] = [
  {
    title: "title",
    url: "https://example.com",
    excerpt: "excerpt",
  },
  {
    title: "title",
    url: "https://example.com/api",
    excerpt: "excerpt",
  },
];

const render = (_: any) => {
  return html`<canary-result-search .items=${items}></canary-result-search> `;
};

export default {
  render,
  title: "Public/canary-search-results",
  parameters: {
    sourceLink: "canary-search-results.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = {
  args: { type: "default" },
};
