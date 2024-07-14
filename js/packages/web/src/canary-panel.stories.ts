import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-panel";
import "./canary-callout-cal";
import "./canary-callout-discord";

const render = ({ type }: any) => {
  if (type === "callout") {
    return html`
      <canary-panel
        slot="body"
        key="key"
        endpoint="http://localhost:6006"
        query="hi"
      >
        <canary-callout-cal slot="callout"></canary-callout-cal>
        <canary-callout-discord slot="callout"></canary-callout-discord>
      </canary-panel>
    `;
  }
  return html`
    <canary-panel
      slot="body"
      key="key"
      endpoint="http://localhost:6006"
      query="hi"
    ></canary-panel>
  `;
};

export default {
  render,
  title: "Public/canary-panel",
  parameters: {
    sourceLink: "canary-panel.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = { args: {} };
export const WithCallout: StoryObj = { args: { type: "callout" } };
