import { html } from "lit";

import type { Meta, StoryObj } from "@storybook/web-components";
import { userEvent } from "@storybook/test";
import { getAllByShadowRole } from "shadow-dom-testing-library";

import "./canary-trigger-searchbar";

import "./canary-content";
import "./canary-input";

import "./canary-search";
import "./canary-search-results";
import "./canary-filter-tabs-glob";

const type = (text: string): StoryObj["play"] => {
  return async ({ canvasElement }) => {
    const [input] = getAllByShadowRole(canvasElement, "textbox");
    await userEvent.type(input, text);
  };
};

enum Kind {
  TriggerSearchBarBackbround,
  SearchContainerPadding,
  MatchBorder,
  ActiveTab,
}

export default {
  title: "examples/styling",
  decorators: [
    (story, { args: { kind } }) => {
      if (kind === Kind.TriggerSearchBarBackbround) {
        return html`
          <style>
            canary-trigger-searchbar::part(button) {
              background-color: red;
            }
          </style>
          ${story()}
        `;
      }

      if (kind === Kind.SearchContainerPadding) {
        return html`
          <style>
            canary-input::part(container) {
              padding: 0px 32px;
            }
            canary-search::part(container) {
              padding: 0px 20px;
            }
          </style>
          ${story()}
        `;
      }

      if (kind === Kind.MatchBorder) {
        return html`
          <style>
            canary-search-results::part(match-group) {
              padding: 12px 12px;
            }
            canary-search-results::part(match-item) {
              padding: 12px 12px;
              background-color: red;
            }
          </style>
          ${story()}
        `;
      }

      if (kind === Kind.ActiveTab) {
        return html`
          <style>
            canary-filter-tabs-glob::part(tab) {
              background-color: gray;
            }
            canary-filter-tabs-glob::part(tab inactive) {
              border: 1px solid red;
            }
            canary-filter-tabs-glob::part(tab active) {
              border: 1px solid blue;
            }
            canary-filter-tabs-glob::part(label) {
              font-weight: bold;
            }
          </style>
          ${story()}
        `;
      }

      throw new Error();
    },
  ],
  parameters: { sourceLink: "components/styling.stories.ts" },
  render: ({ kind }: { kind: Kind }) => {
    if (kind === Kind.TriggerSearchBarBackbround) {
      return html` <canary-trigger-searchbar></canary-trigger-searchbar> `;
    }

    if (
      kind === Kind.SearchContainerPadding ||
      kind === Kind.MatchBorder ||
      kind === Kind.ActiveTab
    ) {
      return html`
        <canary-content>
          <canary-input slot="input"></canary-input>
          <canary-search slot="mode">
            <canary-filter-tabs-glob
              slot="head"
              tabs=${JSON.stringify([
                { name: "All", pattern: "**/*" },
                { name: "API", pattern: "**/api/**" },
              ])}
            ></canary-filter-tabs-glob>
            <canary-search-results slot="body"></canary-search-results>
          </canary-search>
          <canary-ask slot="mode">
            <canary-ask-results slot="body"></canary-ask-results>
          </canary-ask>
        </canary-content>
      `;
    }

    throw new Error();
  },
} satisfies Meta<{ kind: Kind }>;

export const TriggerSearchBarBackbround: StoryObj = {
  args: { kind: Kind.TriggerSearchBarBackbround },
};

export const SearchContainerPadding: StoryObj = {
  args: { kind: Kind.SearchContainerPadding },
  play: type("20hi"),
};

export const MatchBorder: StoryObj = {
  args: { kind: Kind.MatchBorder },
  play: type("20hi"),
};

export const ActiveTab: StoryObj = {
  args: { kind: Kind.ActiveTab },
  play: type("20hi"),
};
