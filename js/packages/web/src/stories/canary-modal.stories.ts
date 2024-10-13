import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import { userEvent } from "@storybook/test";
import * as shadow from "shadow-dom-testing-library";

import "../components/canary-provider-cloud";
import "../components/canary-modal";
import "../components/canary-trigger-searchbar";
import "../components/canary-content";
import "../components/canary-search";
import "../components/canary-input";
import "../components/canary-search-results";

export default {
  title: "public-components/canary-modal",
  component: "canary-modal",
  parameters: { sourceLink: "components/canary-modal.stories.ts" },
  render: () => {
    return html`
      <canary-modal>
        <canary-trigger-searchbar
          data-testid="trigger"
          slot="trigger"
        ></canary-trigger-searchbar>
        <canary-content slot="content">
          <canary-input slot="input"></canary-input>
          <canary-search slot="mode">
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-modal>
    `;
  },
} satisfies Meta;

export const Default: StoryObj = {
  args: {},
  play: async ({ canvasElement }) => {
    const trigger = shadow.getByShadowTestId(canvasElement, "trigger");
    await userEvent.click(trigger);
  },
};

export const OpenWithTransition: StoryObj = {
  args: {},
  render: () => {
    return html`
      <canary-modal
        transition
        style="
          --canary-transition-duration: 0.5s; 
          --canary-transition-timing: ease;
        "
      >
        <canary-trigger-searchbar
          data-testid="trigger"
          slot="trigger"
        ></canary-trigger-searchbar>
        <canary-content slot="content">
          <canary-input slot="input"></canary-input>
          <canary-search slot="mode">
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-modal>
    `;
  },
  play: async ({ canvasElement }) => {
    const trigger = shadow.getByShadowTestId(canvasElement, "trigger");
    await userEvent.click(trigger);

    await new Promise((resolve) => setTimeout(resolve, 500));
  },
};
