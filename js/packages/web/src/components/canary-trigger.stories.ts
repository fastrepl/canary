import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";

import "./canary-trigger-icon";
import "./canary-trigger-logo";
import "./canary-trigger-searchbar";

enum Kind {
  Icon,
  Logo,
  Searchbar_Cmdk,
  Searchbar_Slash,
  Searchbar_Placements,
  Searchbar_Desktop,
  Searchbar_Mobile,
}

export default {
  title: "Public/canary-trigger",
  parameters: { sourceLink: "components/canary-trigger.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.Icon) {
      return html` <canary-trigger-icon></canary-trigger-icon> `;
    }
    if (kind === Kind.Logo) {
      return html` <canary-trigger-logo></canary-trigger-logo> `;
    }

    if (kind === Kind.Searchbar_Cmdk) {
      return html`
        <canary-trigger-searchbar shortcut="cmdk"></canary-trigger-searchbar>
      `;
    }

    if (kind === Kind.Searchbar_Slash) {
      return html`
        <canary-trigger-searchbar shortcut="slash"></canary-trigger-searchbar>
      `;
    }

    if (kind === Kind.Searchbar_Placements) {
      return html`
        <div style="display: flex; gap: 32px; flex-direction: column">
          <div
            style="display: flex; flex-direction: row; justify-content: space-between"
          >
            <button>left</button>
            <canary-trigger-searchbar shortcut="cmdk">
            </canary-trigger-searchbar>
          </div>

          <div
            style="display: flex; flex-direction: row; justify-content: center"
          >
            <canary-trigger-searchbar shortcut="slash">
            </canary-trigger-searchbar>
          </div>

          <div
            style="display: flex; flex-direction: row; justify-content: space-between"
          >
            <canary-trigger-searchbar shortcut="slash">
            </canary-trigger-searchbar>
            <button>right</button>
          </div>
        </div>
      `;
    }

    if (kind === Kind.Searchbar_Desktop || kind === Kind.Searchbar_Mobile) {
      return html`
        <canary-trigger-searchbar shortcut="slash"></canary-trigger-searchbar>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Icon: StoryObj = {
  args: { kind: Kind.Icon },
  parameters: { viewport: { disable: true } },
};

export const Logo: StoryObj = {
  args: { kind: Kind.Logo },
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Cmdk: StoryObj = {
  args: { kind: Kind.Searchbar_Cmdk },
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Slash: StoryObj = {
  args: { kind: Kind.Searchbar_Slash },
  parameters: { viewport: { disable: true } },
};

export const Searchbar_Placements: StoryObj = {
  args: { kind: Kind.Searchbar_Placements },
  parameters: {
    viewport: { disable: true },
    cssprops: {
      "canary-trigger-searchbar-height": { value: "40px" },
      "canary-trigger-searchbar-max-width": { value: "300px" },
    },
  },
};

export const Searchbar_Desktop: StoryObj = {
  args: { kind: Kind.Searchbar_Desktop },
  parameters: { viewport: { defaultViewport: "desktop", disable: false } },
};

export const Searchbar_Mobile: StoryObj = {
  args: { kind: Kind.Searchbar_Mobile },
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
