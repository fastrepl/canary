import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import { userEvent } from "@storybook/test";
import * as shadow from "shadow-dom-testing-library";

import "./canary-provider-cloud";
import "./canary-modal";
import "./canary-trigger-searchbar";
import "./canary-content";
import "./canary-search";
import "./canary-search-input";
import "./canary-search-results";

const render = (_: any) => {
  return html`
    <canary-provider-cloud key="key" endpoint="http://localhost:6006">
      <canary-modal>
        <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
        <canary-content slot="content">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-modal>
    </canary-provider-cloud>
  `;
};

export default {
  render,
  title: "Public/canary-modal",
  parameters: {
    sourceLink: "canary-modal.stories.ts",
  },
} satisfies Meta;

const play: StoryObj["play"] = async ({ canvasElement }) => {
  const trigger = shadow.getByShadowRole(canvasElement, "button");
  await userEvent.click(trigger);
};

export const Desktop: StoryObj = {
  args: {},
  play,
};

export const Mobile: StoryObj = {
  args: {},
  play,
  parameters: {
    viewport: { defaultViewport: "mobile1", disable: false },
  },
};
