import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import { userEvent } from "@storybook/test";
import * as shadow from "shadow-dom-testing-library";

import "./canary-provider-cloud";
import "./canary-modal";
import "./canary-trigger-searchbar";
import "./canary-content";
import "./canary-search";
import "./canary-input";
import "./canary-search-results";

export default {
  title: "Public/canary-modal",
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
