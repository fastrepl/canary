import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { within, userEvent } from "@storybook/test";

import "./canary-provider-cloud";
import "./canary-modal";
import "./canary-trigger";
import "./canary-content";
import "./canary-input-search";

const render = (_: any) => {
  return html`
    <canary-provider-cloud key="key" endpoint="http://localhost:6006">
      <canary-modal>
        <canary-trigger slot="trigger" data-testid="trigger"></canary-trigger>
        <canary-content slot="content">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-input-ask slot="input-ask"></canary-input-ask>
          <canary-result-search slot="result-search"></canary-result-search>
          <canary-result-ask slot="result-ask"></canary-result-ask>
          <canary-callout-discord
            slot="callout"
            url="https://discord.gg/Y8bJkzuQZU"
          ></canary-callout-discord>
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
  const canvas = within(canvasElement);
  const trigger = canvas.getByTestId("trigger");
  await userEvent.click(trigger);
};

export const Mobile: StoryObj = {
  args: {},
  play,
  parameters: {
    viewport: { defaultViewport: "mobile1", disable: false },
  },
};

export const Light: StoryObj = {
  args: {},
  play,
  parameters: {
    themes: {
      themeOverride: "starlight-ocean-light",
    },
  },
};

export const Dark: StoryObj = {
  args: {},
  play,
  parameters: {
    themes: {
      themeOverride: "starlight-ocean-dark",
    },
  },
};
