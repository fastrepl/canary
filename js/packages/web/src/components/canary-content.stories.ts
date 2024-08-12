import { html } from "lit";
import type { Meta, StoryObj } from "@storybook/web-components";
import { http, HttpResponse } from "msw";

import { userEvent } from "@storybook/test";
import { getAllByShadowRole } from "shadow-dom-testing-library";

import { createEvent, TaskStatus } from "../store";

import "./canary-provider-cloud";
import "./canary-content";
import "./canary-mode-tabs";
import "./canary-mode-breadcrumb";
import "./canary-button-mode";
import "./canary-hero-icon";

import "./canary-ask";
import "./canary-ask-input";
import "./canary-ask-results";

import "./canary-search";
import "./canary-search-input";
import "./canary-search-results";
import "./canary-search-results-tabs";
import "./canary-search-suggestions";

import "./canary-ask";
import "./canary-ask-input";
import "./canary-ask-results";

import "./canary-callout-cal";
import "./canary-callout-discord";

enum Kind {
  Ask,
  Search,
  SearchInitial,
  SearchEmpty,
  SearchSection,
  SearchGroup,
  SearchTabs,
  SearchError,
  SearchCallout,
  SearchMobile,
  SearchAndAskWithModeTabs,
  SearchAndAskWithModeButton,
}

const type = (text: string): StoryObj["play"] => {
  return async ({ canvasElement }) => {
    const [input] = getAllByShadowRole(canvasElement, "textbox");
    await userEvent.type(input, text);
  };
};

const init_ask = (): StoryObj["play"] => {
  return async ({ canvasElement }) => {
    const [input] = getAllByShadowRole(canvasElement, "textbox");
    input.dispatchEvent(
      createEvent({
        type: "_unsafe_set_ask_ctx",
        data: {
          status: TaskStatus.COMPLETE,
          response: "# Title\n\nHello World",
          query: "hello",
          progress: false,
          references: [{ url: "https://example.com", title: "title" }],
        },
      }),
    );
  };
};

export default {
  title: "Public/canary-content",
  parameters: { sourceLink: "components/canary-content.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    const wrapper = (child: any) => html`
      <canary-provider-cloud endpoint="http://localhost:6006" key="key">
        <canary-content> ${child} </canary-content>
      </canary-provider-cloud>
    `;

    if (kind === Kind.Search) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchInitial) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input
            slot="input"
            query="initial query 2"
          ></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchEmpty) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchSection) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-suggestions slot="result"></canary-search-suggestions>
          <canary-search-results slot="result" group></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchGroup) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result" group></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchTabs) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results-tabs
            slot="result"
            group
            tabs="Docs:*;API:/api/.+$"
          ></canary-search-results-tabs>
          <canary-callout-discord slot="callout"></canary-callout-discord>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchCallout) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
          <canary-callout-discord slot="callout"></canary-callout-discord>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchError) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.SearchMobile) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
      `);
    }

    if (kind === Kind.Ask) {
      return wrapper(html`
        <canary-ask slot="mode">
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-ask-results slot="result"></canary-ask-results>
        </canary-ask>
      `);
    }

    if (kind === Kind.SearchAndAskWithModeTabs) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-mode-tabs slot="input-after"></canary-mode-tabs>
          <canary-search-results slot="result"></canary-search-results>
        </canary-search>
        <canary-ask slot="mode">
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-mode-tabs slot="input-after"></canary-mode-tabs>
          <canary-ask-results slot="result"></canary-ask-results>
        </canary-ask>
      `);
    }

    if (kind === Kind.SearchAndAskWithModeButton) {
      return wrapper(html`
        <canary-search slot="mode">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="result"></canary-search-results>
          <div slot="empty">
            <canary-button-mode mode="Ask" text="Ask AI Assistant">
              <canary-hero-icon
                slot="icon"
                name="chat-bubble-left"
              ></canary-hero-icon>
            </canary-button-mode->
          </div>
          <canary-mode-button-ask></canary-mode-button-ask>
        </canary-search>
        <canary-ask slot="mode">
          <canary-mode-breadcrumb
            slot="input-before"
            previous="Search"
            text="Ask AI Assistant"
          >
            <canary-hero-icon slot="icon" name="chat-bubble-left"></canary-hero-icon>
        </canary-mode-breadcrumb>
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-ask-results slot="result"></canary-ask-results>
        </canary-ask>
      `);
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const Search: StoryObj = {
  args: { kind: Kind.Search },
  play: type("20hi"),
};

export const SearchWithInitialQuery: StoryObj = {
  args: { kind: Kind.SearchInitial },
};

export const SearchEmpty: StoryObj = {
  args: { kind: Kind.SearchEmpty },
  play: type("0hi"),
};

export const SearchWithSection: StoryObj = {
  args: { kind: Kind.SearchSection },
  play: type("20hi"),
};

export const SearchWithGroup: StoryObj = {
  args: { kind: Kind.SearchGroup },
  play: type("20hi"),
};

export const SearchWithTabs: StoryObj = {
  args: { kind: Kind.SearchTabs },
  play: type("20hi"),
};

export const SearchCallout: StoryObj = {
  args: { kind: Kind.SearchCallout },
  play: type("20discord"),
};

export const SearchError: StoryObj = {
  args: { kind: Kind.SearchError },
  play: type("20hi"),
  parameters: {
    msw: {
      handlers: {
        search: http.post(/\/api\/v1\/search\/*/, async () => {
          return HttpResponse.json([], { status: 429 });
        }),
      },
    },
  },
};

export const SearchMobile: StoryObj = {
  args: { kind: Kind.SearchMobile },
  play: type("20hi"),
  parameters: { viewport: { defaultViewport: "mobile1", disable: false } },
};

export const Ask: StoryObj = {
  args: { kind: Kind.Ask },
  play: init_ask(),
};

export const SearchAsk1: StoryObj = {
  args: { kind: Kind.SearchAndAskWithModeTabs },
  play: type("20hi"),
};

export const SearchAsk2: StoryObj = {
  args: { kind: Kind.SearchAndAskWithModeButton },
  play: type("0hi"),
};
