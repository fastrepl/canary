import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { within, userEvent } from "@storybook/test";

import "./canary-provider-cloud";
import "./canary-modal";
import "./canary-trigger";
import "./canary-panel";

const render = (_: any) => {
  return html`
    <canary-provider-cloud endpoint="http://localhost:6006" key="key">
      <canary-modal>
        <canary-trigger data-testid="trigger" slot="trigger"></canary-trigger>
        <canary-panel slot="body"></canary-panel>
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
