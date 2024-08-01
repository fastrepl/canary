import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-modal";
import "./canary-trigger-logo";

import "./canary-feedback";
import "./canary-feedback-text";
import "./canary-feedback-textarea";

const render = ({ type }: any) => {
  if (type === "modal") {
    return html`
      <canary-modal>
        <canary-trigger-logo
          slot="trigger"
          text="Feedback"
        ></canary-trigger-logo>
        <canary-feedback slot="content">
          <canary-feedback-text name="Email"></canary-feedback-text>
          <canary-feedback-textarea name="Message"></canary-feedback-textarea>
        </canary-feedback>
      </canary-modal>
    `;
  }
  return html`
    <canary-feedback>
      <canary-feedback-text name="Email"></canary-feedback-text>
      <canary-feedback-textarea name="Message"></canary-feedback-textarea>
    </canary-feedback>
  `;
};

export default {
  render,
  title: "Public/canary-feedback",
  parameters: {
    sourceLink: "canary-feedback.stories.ts",
  },
} satisfies Meta;

export const TwoFields: StoryObj = { args: {} };
export const WithModal: StoryObj = { args: { type: "modal" } };
