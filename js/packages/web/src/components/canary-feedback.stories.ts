import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-modal";
import "./canary-trigger-logo";

import "./canary-feedback-page";
import "./canary-feedback-form";
import "./canary-feedback-text";
import "./canary-feedback-textarea";

export default {
  title: "Public/canary-feedback",
  parameters: { sourceLink: "components/canary-feedback.stories.ts" },
  render: ({ type }: any) => {
    if (type === "page") {
      return html` <canary-feedback-page></canary-feedback-page> `;
    }

    if (type === "modal") {
      return html`
        <canary-modal>
          <canary-trigger-logo
            slot="trigger"
            text="Feedback"
          ></canary-trigger-logo>
          <canary-feedback-form slot="content">
            <canary-feedback-text name="Email"></canary-feedback-text>
            <canary-feedback-textarea name="Message"></canary-feedback-textarea>
          </canary-feedback-form>
        </canary-modal>
      `;
    }
    return html`
      <canary-feedback>
        <canary-feedback-text name="Email"></canary-feedback-text>
        <canary-feedback-textarea name="Message"></canary-feedback-textarea>
      </canary-feedback>
    `;
  },
} satisfies Meta;

export const Page: StoryObj = { args: { type: "page" } };
export const TwoFields: StoryObj = { args: {} };
export const WithModal: StoryObj = { args: { type: "modal" } };
