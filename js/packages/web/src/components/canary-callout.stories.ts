import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-callout-cal";
import "./canary-callout-calendly";
import "./canary-callout-slack";
import "./canary-callout-discord";

const render = ({ type }: any) => {
  const callout = (() => {
    switch (type) {
      case "cal":
        return html`<canary-callout-cal forceShow></canary-callout-cal>`;
      case "calendly":
        return html`
          <canary-callout-calendly forceShow></canary-callout-calendly>
        `;
      case "slack":
        return html` <canary-callout-slack forceShow></canary-callout-slack> `;
      case "discord":
        return html`
          <canary-callout-discord forceShow></canary-callout-discord>
        `;
      default:
        return html`<canary-callout-cal></canary-callout-cal>`;
    }
  })();

  return html` <div style="width: 500px">${callout}</div> `;
};

export default {
  render,
  title: "Public/canary-callout",
  parameters: {
    sourceLink: "components/canary-callout.stories.ts",
  },
} satisfies Meta;

export const Cal: StoryObj = { args: { type: "cal" } };
export const Calendly: StoryObj = { args: { type: "calendly" } };
export const Slack: StoryObj = { args: { type: "slack" } };
export const Discord: StoryObj = { args: { type: "discord" } };
