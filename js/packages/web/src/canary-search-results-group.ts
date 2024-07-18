import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";
import { Task } from "@lit/task";
import { classMap } from "lit/directives/class-map.js";

import { consume } from "@lit/context";
import {
  queryContext,
  modeContext,
  type ModeContext,
  providerContext,
  type ProviderContext,
} from "./contexts";

import type { Reference } from "./types";

import "./canary-reference";
import "./canary-reference-skeleton";
import "./canary-error";

// @ts-ignore
import { parse } from "./grammers/groups";
type GroupDefinition = { name: string; pattern: RegExp | null };

@customElement("canary-search-results-group")
export class CanarySearchResultsGroup extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider!: ProviderContext;

  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query = "";

  @property({ converter: { fromAttribute: parse } })
  groups: GroupDefinition[] = [];
  @state() selectedGroup = "";
  @state() selectedReference = -1;
  @state() references: Reference[] = [];
  @state() groupedReferences: Record<string, Reference[]> = {};

  private _task = new Task(this, {
    task: async ([mode, query], { signal }) => {
      if (mode !== "Search" || query === "") {
        return {};
      }

      const references = await this.provider.search(query, signal);
      this.references = references;

      const grouped = this.groups.reduce(
        (acc, group) => ({ ...acc, [group.name]: [] }),
        {} as Record<string, Reference[]>,
      );

      const fallbackGroup = this.groups.find((group) => group.pattern === null);

      references.forEach((reference) => {
        const matchedGroup = this.groups.find(
          (group) => group.pattern && group.pattern.test(reference.url),
        );

        if (matchedGroup) {
          grouped[matchedGroup.name].push(reference);
        } else if (fallbackGroup) {
          grouped[fallbackGroup.name].push(reference);
        }
      });

      this.groupedReferences = grouped;
      return grouped;
    },
    args: () => [this.mode.current, this.query],
  });

  updated(changedProperties: Map<string, any>) {
    if (
      changedProperties.has("groups") &&
      !this.selectedGroup &&
      this.groups.length > 0
    ) {
      this.selectedGroup = this.groups[0].name;
    }

    if (
      changedProperties.has("references") &&
      this.selectedReference < 0 &&
      this.references.length > 0
    ) {
      this.selectedReference = 0;
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
                  <span class="name">${name}</span>
                  <span class="count"
                    >(${this.groupedReferences[name]?.length ?? 0})</span
                  >
                </label>
              </div>`,
          )}
        </div>

        ${this._task.render({
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
          complete: (groups) =>
            html`${(groups?.[this.selectedGroup] ?? []).map(
              ({ title, url, excerpt }, index) => html`
                <canary-reference
                  title=${title}
                  url=${url}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${index === this.selectedReference}
                  @mouseover=${() => {
                    this.selectedReference = index;
                  }}
                ></canary-reference>
              `,
            )}`,
          error: () => html`<canary-error></canary-error>`,
        })}
      </div>
    `;
  }

  static styles = [
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
        font-family: var(--canary-font-family);
      }

      .tab:hover {
        color: var(--canary-color-white);
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
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 2px;
      }

      .name {
        font-size: 12px;
        font-family: var(--canary-font-family);
        color: var(--canary-color-gray-2);
      }
      .count {
        font-size: 11px;
        font-family: var(--canary-font-family);
        color: var(--canary-color-gray-2);
      }
    `,
  ];
}
