import { LitElement, html, css, noChange, type PropertyValues } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { ref, createRef } from "lit/directives/ref.js";

import { scrollContainer } from "./styles";
import type { SearchReference } from "./types";

import { KeyboardSelectionController, SearchController } from "./controllers";

import "./canary-search-references";
import "./canary-reference-skeleton";
import "./canary-error";

// @ts-ignore
import { parse } from "./grammers/groups";
type GroupDefinition = { name: string; pattern: RegExp | null };

const NAME = "canary-search-results-tabs";

@customElement(NAME)
export class CanarySearchResultsTabs extends LitElement {
  @property({ type: Boolean }) group = false;

  @property({ converter: { fromAttribute: parse } })
  tabs: GroupDefinition[] = [];

  @state() selectedGroup = "";
  @state() groupedReferences: Record<
    string,
    (SearchReference & { index: number })[]
  > = {};

  private _ref = createRef<HTMLElement>();

  private _search = new SearchController(this, 250);
  private _selection = new KeyboardSelectionController<SearchReference>(this, {
    handleEnter: (item) => {
      this.dispatchEvent(
        new CustomEvent("close", { bubbles: true, composed: true }),
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
    if (!this.selectedGroup && this.tabs.length > 0) {
      this.selectedGroup = this.tabs[0].name;
    }

    if (changed.has("groupedReferences") && !changed.has("selectedGroup")) {
      const relevantGroup = Object.entries(this.groupedReferences).reduce(
        (acc, [group, references]) => {
          if (!references?.length || !this.groupedReferences?.[acc]?.length) {
            return acc;
          }

          return references[0].index < this.groupedReferences[acc][0].index
            ? group
            : acc;
        },
        this.selectedGroup,
      );

      this.selectedGroup = relevantGroup;
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
          const selected = name === this.selectedGroup;
          const selectable = counts[name] > 0;

          return html`<div
            @click=${() => selectable && this._handleTabClick(name)}
          >
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${name === this.selectedGroup}
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
      return this._skeletons(5);
    }

    const current = this.groupedReferences[this.selectedGroup] ?? [];
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
    this.selectedGroup = name;
  }

  private _groupReferences(
    references: SearchReference[],
    definitions: GroupDefinition[],
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
