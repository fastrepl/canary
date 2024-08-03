import {
  LitElement,
  html,
  css,
  noChange,
  nothing,
  type PropertyValues,
} from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ref, createRef } from "lit/directives/ref.js";

import type { SearchReference } from "../types";
import { DEBOUNCE_MS, MODE_SEARCH } from "../constants";

import { customEvent } from "../events";
import { KeyboardSelectionController, SearchController } from "../controllers";
import { scrollContainer } from "../styles";

import "./canary-search-references";
import "./canary-reference-skeleton";
import "./canary-error";

// @ts-ignore
import { parse } from "../grammers/tabs";
type TabDefinition = { name: string; pattern: RegExp | null };

const NAME = "canary-search-results-tabs";

@customElement(NAME)
export class CanarySearchResultsTabs extends LitElement {
  readonly MODE = MODE_SEARCH;

  @property({ type: Boolean }) group = false;

  @property({ converter: { fromAttribute: parse } })
  tabs: TabDefinition[] = [];

  @state() selectedTab = "";
  @state() groupedReferences: Record<
    string,
    (SearchReference & { index: number })[]
  > = {};

  private _ref = createRef<HTMLElement>();

  private _search = new SearchController(this, {
    mode: this.MODE,
    debounceTimeoutMs: DEBOUNCE_MS,
  });

  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(customEvent({ name: "modal-close" }));
      window.location.href = item.url;
    },
  });

  connectedCallback(): void {
    super.connectedCallback();

    if (typeof this.tabs === "string") {
      this.tabs = parse(this.tabs);
    }
  }

  updated(changed: PropertyValues<this>) {
    if (!this.selectedTab && this.tabs.length > 0) {
      this.selectedTab = this.tabs[0].name;
    }

    if (changed.has("groupedReferences") && !changed.has("selectedTab")) {
      const relevantGroup = Object.entries(this.groupedReferences).reduce(
        (acc, [group, references]) => {
          if (!references?.length || !this.groupedReferences?.[acc]?.length) {
            return acc;
          }

          return references[0].index < this.groupedReferences[acc][0].index
            ? group
            : acc;
        },
        this.selectedTab,
      );

      this.selectedTab = relevantGroup;
    }
  }

  render() {
    return html`
      <div ${ref(this._ref)} class="container">
        ${this._tabs()}
        ${this._search.render({
          error: () => html`<canary-error></canary-error>`,
          pending: () => this._currentResults(),
          complete: (references) => {
            if (!references) {
              return noChange;
            }
            if (this._ref.value) {
              this._ref.value.scrollTop = 0;
            }

            this.groupedReferences = this._groupReferences(
              references,
              this.tabs,
            );
            return this._currentResults();
          },
        })}
      </div>
    `;
  }

  private _tabs() {
    const counts = Object.fromEntries(
      Object.entries(this.groupedReferences).map(([group, references]) => [
        group,
        references.length,
      ]),
    );

    return html`
      <div class="tabs">
        ${this.tabs.map(({ name }) => {
          const selected = name === this.selectedTab;
          const selectable = counts[name] > 0;

          return html`<div
            @click=${() => selectable && this._handleTabClick(name)}
          >
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${name === this.selectedTab}
            />
            <label class=${classMap({ tab: true, selectable, selected })}>
              ${name}
            </label>
          </div>`;
        })}
      </div>
    `;
  }

  private _currentResults() {
    if (Object.keys(this.groupedReferences).length === 0) {
      return this._search.query ? this._skeletons(5) : nothing;
    }

    const current = this.groupedReferences[this.selectedTab] ?? [];
    this._selection.items = current;

    return html`<canary-search-references
      .references=${current}
      .selected=${this._selection.index}
      .group=${this.group}
    ></canary-search-references>`;
  }

  private _skeletons(n: number) {
    return html` <div class="skeleton-container">
      ${Array(n).fill(
        html`<canary-reference-skeleton></canary-reference-skeleton>`,
      )}
    </div>`;
  }

  private _handleTabClick(name: string): void {
    this.selectedTab = name;
  }

  private _groupReferences(
    references: SearchReference[],
    definitions: TabDefinition[],
  ) {
    const grouped = definitions.reduce(
      (acc, group) => ({ ...acc, [group.name]: [] }),
      {} as Record<string, (SearchReference & { index: number })[]>,
    );

    const fallbackGroup = definitions.find((group) => group.pattern === null);

    references.forEach((reference, index) => {
      const matchedGroup = definitions.find(
        (group) => group.pattern && group.pattern.test(reference.url),
      );

      if (matchedGroup) {
        grouped[matchedGroup.name].push({ ...reference, index });
      } else if (fallbackGroup) {
        grouped[fallbackGroup.name].push({ ...reference, index });
      }
    });

    return grouped;
  }

  static styles = [
    scrollContainer,
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 10px;
        max-height: 425px;
      }

      .skeleton-container {
        display: flex;
        flex-direction: column;
        gap: 8px;
        height: 425px;
      }
    `,
    css`
      .tabs {
        display: flex;
        flex-direction: row;
        align-items: center;

        gap: 8px;
        padding-left: 4px;

        color: var(--canary-color-gray-50);
        text-decoration-color: var(--canary-color-gray-50);
      }

      .tab {
        cursor: pointer;
      }

      .selectable.tab:hover {
        color: var(--canary-color-gray-10);
        text-decoration: underline;
      }

      .selected.tab {
        color: var(--canary-color-gray-10);
        text-decoration: underline;
        text-decoration-color: var(--canary-color-gray-10);
      }

      input {
        display: none;
      }
      label {
        font-size: 12px;
        text-decoration-skip-ink: none;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResultsTabs;
  }
}
