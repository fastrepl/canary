import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { http, HttpResponse } from "msw";

import "./canary-provider-cloud";
import "./canary-content";

import "./canary-input-search";
import "./canary-input-ask";

import "./canary-result-search";
import "./canary-result-ask";

import "./canary-callout-cal";
import "./canary-callout-discord";

const render = ({ type }: any) => {
  if (type === "search") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-group") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-input-search slot="input-search"> </canary-input-search>
          <canary-result-search
            slot="result-search"
            groups="Docs:*;API:api"
          ></canary-result-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-callout") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="discord">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
          <canary-callout-discord slot="callout"></canary-callout-discord>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-empty") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content>
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-error") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-ask") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
          <canary-input-ask slot="input-ask"></canary-input-ask>
          <canary-result-ask slot="result-ask"></canary-result-ask>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-ask-empty") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content>
          <canary-result-search slot="result-search"></canary-result-search>
          <canary-input-ask slot="input-ask"></canary-input-ask>
          <canary-result-ask slot="result-ask"></canary-result-ask>
          <canary-input-search slot="input-search"></canary-input-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-ask-error") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-input-search slot="input-search"></canary-input-search>
          <canary-result-search slot="result-search"></canary-result-search>
          <canary-input-ask slot="input-ask"></canary-input-ask>
          <canary-result-ask slot="result-ask"></canary-result-ask>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  return html`<canary-content></canary-content>`;
};

export default {
  render,
  title: "Public/canary-content",
  parameters: {
    sourceLink: "canary-content.stories.ts",
  },
} satisfies Meta;

export const Search: StoryObj = {
  args: { type: "search" },
};

export const SearchGroup: StoryObj = {
  args: { type: "search-group" },
};

export const SearchEmpty: StoryObj = {
  args: { type: "search-empty" },
};

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

export const SearchCallout: StoryObj = {
  args: { type: "search-callout" },
};

export const SearchMobile: StoryObj = {
  args: { type: "search" },
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};

export const SearchAsk: StoryObj = {
  args: { type: "search-ask" },
};

export const SearchAskEmpty: StoryObj = {
  args: { type: "search-ask-empty" },
};

export const SearchAskError: StoryObj = {
  args: { type: "search-ask-error" },
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
