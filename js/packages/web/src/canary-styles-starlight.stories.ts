import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import "./canary-styles-starlight";
import "./canary-trigger-searchbar";

const render = (_: any) => {
  return html`
    <canary-styles-starlight>
      <canary-trigger-searchbar></canary-trigger-searchbar>
    </canary-styles-starlight>
  `;
};

export default {
  render,
  title: "Public/canary-styles-starlight",
  parameters: {
    sourceLink: "canary-styles-starlight.stories.ts",
  },
} satisfies Meta;

export const Default: StoryObj = {
  args: {},
  parameters: {
    cssprops: {
      "sl-color-accent-low": { value: "#b0deff" },
      "sl-color-accent": { value: "#0073aa" },
      "sl-color-accent-high": { value: "#003653" },
      "sl-color-white": { value: "#121a1c" },
      "sl-color-gray-1": { value: "#182a2f" },
      "sl-color-gray-2": { value: "#2a3b41" },
      "sl-color-gray-3": { value: "#495c62" },
      "sl-color-gray-4": { value: "#7b8f96" },
      "sl-color-gray-5": { value: "#bac4c8" },
      "sl-color-gray-6": { value: "#e7eff2" },
      "sl-color-gray-7": { value: "#f3f7f9" },
      "sl-color-black": { value: "#ffffff" },
    },
  },
};
