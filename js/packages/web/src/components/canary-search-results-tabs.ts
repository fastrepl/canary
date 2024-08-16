import { LitElement, html, css, nothing, type PropertyValues } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { consume } from "@lit/context";
import { searchContext } from "../contexts";
import { KeyboardSelectionController } from "../controllers";

import type { SearchContext, SearchReference } from "../types";
import { TaskStatus } from "../store/managers";
import { MODAL_CLOSE_EVENT } from "./canary-modal";

import "./canary-search-references";
import "./canary-error";

// @ts-ignore
import { parse } from "../grammers/tabs";
type TabDefinition = { name: string; pattern: RegExp | null };

const NAME = "canary-search-results-tabs";

@customElement(NAME)
export class CanarySearchResultsTabs extends LitElement {
  @property({ type: String })
  header = "";

  @property({ type: Boolean })
  group = false;

  @property({ converter: { fromAttribute: parse } })
  tabs: TabDefinition[] = [];

  @consume({ context: searchContext, subscribe: true })
  @state()
  private _search?: SearchContext;

  @state() _selectedTab = "";
  @state() _groupedReferences: Record<
    string,
    (SearchReference & { index: number })[]
  > = {};

  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(
        new CustomEvent(MODAL_CLOSE_EVENT, { bubbles: true, composed: true }),
      );
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

      this._selectedTab = relevantGroup;
    }
  }

  render() {
    if (!this._search || this._search.result.search.length === 0) {
      return nothing;
    }

    if (this._search.status === TaskStatus.COMPLETE) {
      this._groupedReferences = this._groupReferences(
        this._search.result.search,
        this.tabs,
      );
    }

    return html`
      <div class="container">
        ${this._tabs()}
        <div>
          ${this._search.status === TaskStatus.ERROR
            ? html`<canary-error></canary-error>`
            : this._currentResults()}
        </div>
      </div>
    `;
  }

  private _tabs() {
    const counts = Object.fromEntries(
      Object.entries(this._groupedReferences).map(([group, references]) => [
        group,
        references.length,
      ]),
    );

    return html`
      <div class="tabs">
        ${this.tabs.map(({ name }) => {
          const selected = name === this._selectedTab;
          const selectable = counts[name] > 0;

          return html`<div
            @click=${() => selectable && this._handleTabClick(name)}
          >
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${name === this._selectedTab}
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
    const current = this._groupedReferences[this._selectedTab] ?? [];
    this._selection.items = current;

    return html`
      ${this.header && html`<div class="header">${this.header}</div>`}

      <div class="items">
        <canary-search-references
          .references=${current}
          .selected=${this._selection.index}
          .group=${this.group}
        ></canary-search-references>
      </div>
    `;
  }

  private _handleTabClick(name: string): void {
    this._selectedTab = name;
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
    css`
      .container {
        display: flex;
        flex-direction: column;
        gap: 4px;
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

        padding-left: 2px;
        gap: 8px;

        color: var(--canary-color-gray-50);
        text-decoration-color: var(--canary-color-gray-50);
      }

      .selectable.tab {
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
        font-size: 0.75rem;
        text-decoration-skip-ink: none;
      }

      .header {
        margin: 4px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResultsTabs;
  }
}
