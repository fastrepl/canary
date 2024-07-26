import {
  LitElement,
  html,
  css,
  nothing,
  noChange,
  type PropertyValues,
} from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";
import { classMap } from "lit/directives/class-map.js";

import { scrollContainer } from "./styles";
import type { Reference } from "./types";

import { KeyboardSelectionController, SearchController } from "./controllers";

import "./canary-reference";
import "./canary-reference-skeleton";
import "./canary-error";

// @ts-ignore
import { parse } from "./grammers/groups";
type GroupDefinition = { name: string; pattern: RegExp | null };

const NAME = "canary-search-results-group";

@customElement(NAME)
export class CanarySearchResultsGroup extends LitElement {
  @property({ converter: { fromAttribute: parse } })
  groups: GroupDefinition[] = [];

  @state() selectedGroup = "";
  @state() groupedReferences: Record<string, Reference[]> = {};
  @state() groupCounts: Record<string, number> = {};

  private _search = new SearchController(this);
  private _selection = new KeyboardSelectionController<Reference>(this, {
    handleEnter: (item) => {
      window.open(item.url, "_blank");
    },
  });

  updated(changed: PropertyValues<this>) {
    if (changed.get("groupedReferences") && !this.selectedGroup) {
      this.selectedGroup = this.groups[0].name;
    }
  }

  render() {
    return html`
      <div class="container">
        ${this._tabs()}
        ${this._search.render({
          error: () => html`<canary-error></canary-error>`,
          initial: () => this._skeletons(5),
          pending: () => this._skeletons(5),
          complete: (references) => {
            if (!references) {
              return noChange;
            }

            this.groupedReferences = this._groupReferences(
              references,
              this.groups,
            );

            return nothing;
          },
        })}
        ${this._currentResults()}
      </div>
    `;
  }

  private _tabs() {
    return html`
      <div class="tabs">
        ${this.groups.map(
          ({ name }) =>
            html`<div @click=${() => this._handleTabClick(name)}>
              <input
                type="radio"
                name="mode"
                .id=${name}
                .value=${name}
                ?checked=${name === this.selectedGroup}
              />
              <label
                class=${classMap({
                  tab: true,
                  selectable: this.groupCounts[name] > 0,
                  selected: name === this.selectedGroup,
                })}
              >
                ${name}
              </label>
            </div>`,
        )}
      </div>
    `;
  }

  private _currentResults() {
    const grouped = this.groupedReferences;

    this.groupCounts = Object.fromEntries(
      Object.entries(grouped).map(([group, references]) => [
        group,
        references.length,
      ]),
    );

    const current = grouped[this.selectedGroup] ?? [];
    this._selection.items = current;

    return html`${current.map(
      ({ title, url, excerpt }, index) => html`
        <canary-reference
          title=${title}
          url=${url}
          excerpt=${ifDefined(excerpt)}
          ?selected=${index === this._selection.index}
        ></canary-reference>
      `,
    )}`;
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
    references: Reference[],
    definitions: GroupDefinition[],
  ) {
    const grouped = definitions.reduce(
      (acc, group) => ({ ...acc, [group.name]: [] }),
      {} as Record<string, Reference[]>,
    );

    const fallbackGroup = definitions.find((group) => group.pattern === null);

    references.forEach((reference) => {
      const matchedGroup = definitions.find(
        (group) => group.pattern && group.pattern.test(reference.url),
      );

      if (matchedGroup) {
        grouped[matchedGroup.name].push(reference);
      } else if (fallbackGroup) {
        grouped[fallbackGroup.name].push(reference);
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
    [NAME]: CanarySearchResultsGroup;
  }
}
