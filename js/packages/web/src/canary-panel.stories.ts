import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { http, HttpResponse } from "msw";

import "./canary-panel";
import "./canary-callout-cal";
import "./canary-callout-discord";

const render = ({ type }: any) => {
  if (type === "search-empty") {
    return html`
      <canary-panel key="key" endpoint="http://localhost:6006"> </canary-panel>
    `;
  }

  if (type === "search-query") {
    return html`
      <canary-panel key="key" endpoint="http://localhost:6006" query="hi">
      </canary-panel>
    `;
  }

  if (type === "search-error") {
    return html`
      <canary-panel key="key" endpoint="http://localhost:6006" query="hi">
      </canary-panel>
    `;
  }

  if (type === "search-callout") {
    return html`
      <canary-panel key="key" endpoint="http://localhost:6006" query="discord">
        <canary-callout-cal slot="callout"></canary-callout-cal>
        <canary-callout-discord
          forceShow
          slot="callout"
        ></canary-callout-discord>
      </canary-panel>
    `;
  }

  return html`<canary-panel></canary-panel>`;
};

export default {
  render,
  title: "Public/canary-panel",
  parameters: {
    sourceLink: "canary-panel.stories.ts",
  },
} satisfies Meta;

export const Mobile: StoryObj = {
  args: { type: "search-query" },
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
export const SearchLight: StoryObj = {
  args: { type: "search-query" },
  parameters: { themes: { themeOverride: "starlight-ocean-light" } },
};
export const SearchDark: StoryObj = {
  args: { type: "search-query" },
  parameters: { themes: { themeOverride: "starlight-ocean-dark" } },
};
export const SearchEmpty: StoryObj = { args: { type: "search-empty" } };
export const SearchError: StoryObj = {
  args: { type: "search-error" },
  parameters: {
    msw: {
      handlers: {
        search: http.post("/api/v1/search", async () => {
          return HttpResponse.json([], { status: 429 });
        }),
      },
    },
  },
};
export const SearchWithCallout: StoryObj = { args: { type: "search-callout" } };
