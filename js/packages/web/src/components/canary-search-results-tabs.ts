import { LitElement, html, css, nothing, type PropertyValues } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";

import pm from "picomatch";

import type { SearchContext, SearchReference, TabDefinitions } from "../types";
import { parseURL } from "../utils";
import { createEvent } from "../store";
import { TaskStatus } from "../store/managers";

import "./canary-error";
import "./canary-tabs-url";
import "./canary-search-references";

const NAME = "canary-search-results-tabs";

@customElement(NAME)
export class CanarySearchResultsTabs extends LitElement {
  @property({ type: Boolean })
  group = false;

  @property({ type: Array })
  tabs: TabDefinitions = [{ name: "All", pattern: "**/*" }];

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  @state() _selectedTab = "";
  @state() _groupedReferences: Record<
    string,
    (SearchReference & { index: number })[]
  > = {};

  connectedCallback(): void {
    super.connectedCallback();

    if (typeof this.tabs === "string") {
      this.tabs = JSON.parse(this.tabs);
    }

    this.dispatchEvent(createEvent({ type: "register_tab", data: this.tabs }));
  }

  updated(changed: PropertyValues<this>) {
    if (!this._selectedTab && this.tabs.length > 0) {
      this._selectedTab = this.tabs[0].name;
    }

    if (changed.has("_groupedReferences") && !changed.has("_selectedTab")) {
      const relevantGroup = Object.entries(this._groupedReferences).reduce(
        (acc, [group, references]) => {
          if (!references?.length) {
            return acc;
          }

          return references[0].index <
            (this._groupedReferences[acc]?.[0]?.index ?? 999)
            ? group
            : acc;
        },
        this._selectedTab,
      );

      this._handleChangeTab(relevantGroup);
    }
  }

  render() {
    if (!this._search || this._search.result.search.length === 0) {
      return nothing;
    }

    if (this._search.status === TaskStatus.COMPLETE) {
      this._groupedReferences = this._groupReferences(
        this._search.result.search.flatMap(({ hits }) => hits),
        this.tabs,
      );
    }

    return html`
      <div class="container">
        <div class="tab-container">
          <canary-tabs-url
            .tabs=${this.tabs.map(({ name }) => name)}
            .selected=${this._selectedTab}
            @tab-change=${this._handleChangeTabEvent}
          ></canary-tabs-url>
        </div>
        <div>
          ${this._search.status === TaskStatus.ERROR
            ? html`<canary-error></canary-error>`
            : this._currentResults()}
        </div>
      </div>
    `;
  }

  private _currentResults() {
    const current = this._groupedReferences[this._selectedTab] ?? [];

    return html`
      <canary-search-references
        .references=${current}
        .group=${this.group}
      ></canary-search-references>
    `;
  }

  private _handleChangeTabEvent(e: CustomEvent<string>) {
    this._handleChangeTab(e.detail);
  }

  private _handleChangeTab(name: string): void {
    this._selectedTab = name;

    const index = this.tabs.findIndex((tab) => tab.name === name);
    this.dispatchEvent(createEvent({ type: "set_tab", data: index }));
  }

  private _groupReferences(
    references: SearchReference[],
    definitions: TabDefinitions,
  ) {
    const grouped = definitions.reduce(
      (acc, group) => ({ ...acc, [group.name]: [] }),
      {} as Record<string, (SearchReference & { index: number })[]>,
    );

    const matchers = definitions.map((d) => pm(d.pattern));

    references.forEach((ref, index) => {
      const item = { ...ref, index };
      const { pathname } = parseURL(ref.url);

      for (let i = 0; i < matchers.length; i++) {
        if (matchers[i](pathname)) {
          grouped[definitions[i].name].push(item);
        }
      }
    });

    return grouped;
  }

  static styles = [
    css`
      .container {
        display: flex;
        flex-direction: column;
      }

      .tab-container {
        position: sticky;
        top: 0px;
        background-color: var(--canary-color-gray-100);
        z-index: 50;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResultsTabs;
  }
}
