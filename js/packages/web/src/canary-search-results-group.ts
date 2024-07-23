import { LitElement, html, css, type PropertyValues } from "lit";
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
  readonly groups: GroupDefinition[] = [];

  @state() selectedGroup = "";
  @state() groupedReferences: Record<string, Reference[]> = {};

  private search = new SearchController(this);
  private selection = new KeyboardSelectionController<Reference>(this, {
    handleEnter: (item) => {
      window.open(item.url, "_blank");
    },
  });

  updated(changed: PropertyValues<this>) {
    if (
      changed.has("groups") &&
      !this.selectedGroup &&
      this.groups.length > 0
    ) {
      this.selectedGroup = this.groups[0].name;
    }
  }
  render() {
    return html`
      <div class="container">
        <div class="tabs">
          ${this.groups.map(
            ({ name }, index) =>
              html`<div
                class=${classMap({
                  tab: true,
                  selected: name === this.selectedGroup,
                  left: index === 0,
                  right: index === this.groups.length - 1,
                })}
                @click=${() => (this.selectedGroup = name)}
              >
                <input
                  type="radio"
                  name="mode"
                  .id=${name}
                  .value=${name}
                  ?checked=${name === this.selectedGroup}
                />
                <label>
                  ${`${name} (${this.groupedReferences[name]?.length ?? 0})`}
                </label>
              </div>`,
          )}
        </div>

        ${this.search.render({
          initial: () =>
            html` <div class="skeleton-container">
              ${Array(4).fill(
                html`<canary-reference-skeleton></canary-reference-skeleton>`,
              )}
            </div>`,
          pending: () =>
            html` <div class="skeleton-container">
              ${Array(5).fill(
                html`<canary-reference-skeleton></canary-reference-skeleton>`,
              )}
            </div>`,
          complete: (references) => {
            const grouped = this._groupReferences(references, this.groups);
            this.groupedReferences = grouped;

            const current = grouped[this.selectedGroup] ?? [];

            this.selection.items = current;

            return html`${current.map(
              ({ title, url, excerpt }, index) => html`
                <canary-reference
                  title=${title}
                  url=${url}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${index === this.selection.index}
                  @mouseover=${() => {
                    this.selection.index = index;
                  }}
                ></canary-reference>
              `,
            )}`;
          },

          error: () => html`<canary-error></canary-error>`,
        })}
      </div>
    `;
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
        overflow-y: hidden;
      }
      .container:hover {
        overflow-y: auto;
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
        cursor: pointer;
        display: flex;
        flex-direction: row;
        align-items: center;

        gap: 8px;
        padding-left: 4px;
        color: var(--canary-color-gray-10);
      }

      .tab:hover {
        color: var(--canary-color-gray-0);
        text-decoration: underline;
      }

      .selected {
        text-decoration: underline;
      }

      input {
        display: none;
      }
    `,
    css`
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
