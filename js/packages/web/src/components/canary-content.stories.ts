import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { http, HttpResponse } from "msw";

import { userEvent } from "@storybook/test";
import { getByShadowRole } from "shadow-dom-testing-library";

import "./canary-provider-cloud";
import "./canary-content";

import "./canary-ask";
import "./canary-ask-input";
import "./canary-ask-results";

import "./canary-search";
import "./canary-search-input";
import "./canary-search-results";
import "./canary-search-results-tabs";

import "./canary-callout-cal";
import "./canary-callout-discord";

enum Kind {
  Search,
  SearchEmpty,
  SearchGroup,
  SearchTabs,
  SearchError,
  SearchCallout,
  SearchMobile,
}

const type = (text: string): StoryObj["play"] => {
  return async ({ canvasElement }) => {
    const input = getByShadowRole(canvasElement, "textbox");
    await userEvent.type(input, text);
  };
};

export default {
  title: "Public/canary-content",
  parameters: { sourceLink: "canary-content.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    const wrapper = (child: any) => html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content> ${child} </canary-content>
      </canary-provider-cloud>
    `;

    if (kind === Kind.Search) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchEmpty) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchGroup) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results" group></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchTabs) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results-tabs
            slot="results"
            group
            tabs="Docs:*;API:/api/.+$"
          ></canary-search-results-tabs>
          <canary-callout-discord slot="callout"></canary-callout-discord>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchCallout) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
          <canary-callout-discord slot="callout"></canary-callout-discord>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchError) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchMobile) {
      return wrapper(html`
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
      `);
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Search: StoryObj = {
  args: { kind: Kind.Search },
  play: type("hi"),
};

export const SearchEmpty: StoryObj = {
  args: { kind: Kind.SearchEmpty },
};

export const SearchWithGroup: StoryObj = {
  args: { kind: Kind.SearchGroup },
  play: type("hi"),
};

export const SearchWithTabs: StoryObj = {
  args: { kind: Kind.SearchTabs },
  play: type("hi"),
};

export const SearchCallout: StoryObj = {
  args: { kind: Kind.SearchCallout },
  play: type("discord"),
};

export const SearchError: StoryObj = {
  args: { kind: Kind.SearchError },
  play: type("hi"),
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

export const SearchMobile: StoryObj = {
  args: { kind: Kind.SearchMobile },
  play: type("hi"),
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};
