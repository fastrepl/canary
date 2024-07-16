import { LitElement, html, css } from "lit";
import { customElement, state, property } from "lit/decorators.js";
import { ifDefined } from "lit/directives/if-defined.js";

import { consume } from "@lit/context";
import { ProviderContext, providerContext, queryContext } from "./contexts";

import { Task } from "@lit/task";
import { Reference } from "./types";

import "./canary-reference";
import "./canary-reference-skeleton";

// @ts-ignore
import { parse } from "./grammers/groups.js";

@customElement("canary-result-search")
export class CanaryResultSearch extends LitElement {
  @consume({ context: providerContext, subscribe: false })
  @state()
  provider!: ProviderContext;

  @consume({ context: queryContext, subscribe: true })
  @state()
  query = "";

  @property({ converter: (v) => parse(v), reflect: true })
  groups: Record<string, RegExp | null> = {};

  @state() references: Reference[] = [];
  @state() selectedIndex = 0;

  private _task = new Task(this, {
    task: async ([query], { signal }) => {
      const result = await this.provider.search(query, signal);
      this.references = result;
      return null;
    },
    args: () => [this.query],
  });

  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("keydown", this._handleNavigation);
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this._handleNavigation);
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
              ${Array(4).fill(
                html`<canary-reference-skeleton></canary-reference-skeleton>`,
              )}
            </div>`,
          complete: () =>
            html`${this.references.map(
              ({ title, url, excerpt }, index) => html`
                <canary-reference
                  title=${title}
                  url=${url}
                  excerpt=${ifDefined(excerpt)}
                  ?selected=${index === this.selectedIndex}
                  @mouseover=${() => {
                    this.selectedIndex = index;
                  }}
                ></canary-reference>
              `,
            )}`,
        })}
      </div>
    `;
  }
  private _handleNavigation = (e: KeyboardEvent) => {
    switch (e.key) {
      case "ArrowUp":
        e.preventDefault();
        this._moveSelection(-1);
        break;
      case "ArrowDown":
        e.preventDefault();
        this._moveSelection(1);
        break;
      case "Enter":
        e.preventDefault();

        const item = this.references?.[this.selectedIndex];
        if (item) {
          window.open(item.url, "_blank");
        }
        break;
    }
  };

  private _moveSelection(delta: number) {
    const next = this.selectedIndex + delta;
    if (next > -1 && next < this.references.length) {
      this.selectedIndex = next;
    }
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
      gap: 8px;
      max-height: 50vh;
      overflow-y: hidden;
    }

    .container:hover {
      overflow-y: auto;
    }

    .skeleton-container {
      display: flex;
      flex-direction: column;
      gap: 8px;
      height: 325px;
    }
  `;
}
