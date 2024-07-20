import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";
import { Task } from "@lit/task";

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

const NAME = "canary-search-results";

@customElement(NAME)
export class CanarySearchResults extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider!: ProviderContext;

  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode!: ModeContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query = "";

  @state() references: Reference[] = [];
  @state() selected = -1;

  private _task = new Task(this, {
    task: async ([mode, query], { signal }) => {
      if (mode !== "Search" || query === "") {
        return [];
      }

      const result = await this.provider.search(query, signal);
      this.references = result;
      return result;
    },
    args: () => [this.mode.current, this.query],
  });

  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("keydown", this._handleKeyDown);
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this._handleKeyDown);
    super.disconnectedCallback();
  }

  updated(changedProperties: Map<string, any>) {
    if (
      changedProperties.has("references") &&
      this.selected < 0 &&
      this.references.length > 0
    ) {
      this.selected = 0;
    }
  }

  render() {
    return html`
      <div class="container">
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
          complete: (references) =>
            html`${references.map(
              ({ title, url, excerpt }, index) => html`
                <canary-reference
                  title=${title}
                  url=${url}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${index === this.selected}
                  @mouseover=${() => {
                    this.selected = index;
                  }}
                ></canary-reference>
              `,
            )}`,
          error: () => html`<canary-error></canary-error>`,
        })}
      </div>
    `;
  }

  private _moveSelection(delta: number) {
    const next = this.selected + delta;
    if (next > -1 && next < this.references.length) {
      this.selected = next;

      this.dispatchEvent(
        new CustomEvent("results-select", {
          bubbles: true,
          composed: true,
          detail: this.references[this.selected],
        }),
      );
    }
  }

  private _handleKeyDown = (e: KeyboardEvent) => {
    switch (e.key) {
      case "ArrowUp":
        e.preventDefault();
        this._moveSelection(-1);
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveSelection(1);
        break;
    }
  };

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 8px;
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
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearchResults;
  }
}
