import { LitElement, html, css } from "lit";
import { customElement, state } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";
import { Task } from "@lit/task";

import { consume } from "@lit/context";
import {
  providerContext,
  type ProviderContext,
  queryContext,
} from "./contexts";

import type { Reference } from "./types";

import "./canary-reference";
import "./canary-reference-skeleton";
import "./canary-error";

@customElement("canary-search-results")
export class CanarySearchResults extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider!: ProviderContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query = "";

  @state() references: Reference[] = [];
  @state() selected = -1;

  private _task = new Task(this, {
    task: async ([query], { signal }) => {
      const result = await this.provider.search(query, signal);
      return result;
    },
    args: () => [this.query],
  });

  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("keydown", this._handleUpDown);
    this.addEventListener("keydown", this._handleEnter);
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this._handleUpDown);
    this.removeEventListener("keydown", this._handleEnter);
    super.disconnectedCallback();
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
    }
  }

  private _handleUpDown = (e: KeyboardEvent) => {
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

  private _handleEnter = (e: KeyboardEvent) => {
    if (e.key !== "Enter") {
      e.preventDefault();

      if (this.selected < 0) {
        return;
      }

      const item = this.references?.[this.selected];
      if (item) {
        window.open(item.url, "_blank");
      }
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
