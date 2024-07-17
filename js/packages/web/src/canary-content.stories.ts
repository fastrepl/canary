import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { http, HttpResponse } from "msw";

import "./canary-provider-cloud";
import "./canary-content";

import "./canary-ask";
import "./canary-ask-input";
import "./canary-ask-results";

import "./canary-search";
import "./canary-search-input";
import "./canary-search-results";
import "./canary-search-results-group";

import "./canary-callout-cal";
import "./canary-callout-discord";

const render = ({ type }: any) => {
  if (type === "search") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-group") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results-group
              slot="results"
              groups="Docs:*;API:/api/.+$"
            ></canary-search-results-group>
          </canary-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-callout") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="discord">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
            <canary-callout-discord slot="callout"></canary-callout-discord>
          </canary-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-error") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
          </canary-search>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "ask") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content>
          <canary-ask slot="ask">
            <canary-ask-input slot="input"></canary-ask-input>
            <canary-ask-results slot="results"></canary-ask-results>
          </canary-ask>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-ask") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
          </canary-search>
          <canary-ask slot="ask">
            <canary-ask-input slot="input"></canary-ask-input>
            <canary-ask-results slot="results"></canary-ask-results>
          </canary-ask>
        </canary-content>
      </canary-provider-cloud>
    `;
  }

  if (type === "search-ask-error") {
    return html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content query="hi">
          <canary-search-input slot="search-input"></canary-search-input>
          <canary-search slot="search"></canary-search>
          <canary-ask-input slot="ask-input"></canary-ask-input>
          <canary-ask slot="ask"></canary-ask>
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

export const Ask: StoryObj = {
  args: { type: "ask" },
};

export const SearchAsk: StoryObj = {
  args: { type: "search-ask" },
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
