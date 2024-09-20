import { LitElement, css, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import pm from "picomatch";

import { createEvent } from "../store";
import type { TabDefinitions } from "../types";
import { parseURL } from "../utils";

const NAME = "canary-filter-tabs-glob";

@customElement(NAME)
export class CanaryFilterTabsGlob extends LitElement {
  @property({ type: Array })
  tabs: TabDefinitions = [{ name: "All", pattern: "**/*" }];

  @state()
  private _selected!: string;

  connectedCallback(): void {
    super.connectedCallback();
    this._ensureTabs();
    this._ensureSelected();

    this.dispatchEvent(
      createEvent({
        type: "set_filter",
        data: {
          name: NAME,
          filter: {
            args: { tab: this._selected },
            fn: (matches, { tab }: { tab: string }) => {
              const { pattern } = this.tabs.find(({ name }) => name === tab)!;
              const matcher = pm(pattern);

              return matches.filter((m) => {
                const { pathname } = parseURL(m.url);
                return matcher(pathname);
              });
            },
          },
        },
      }),
    );
  }

  render() {
    return html`
      <div class="container">
        ${this.tabs.map(({ name }) => {
          const selected = name === this._selected;

          return html`<div @click=${() => this._handleChangeTab(name)}>
            <input
              type="radio"
              name="mode"
              .id=${name}
              .value=${name}
              ?checked=${selected}
            />
            <label class=${classMap({ tab: true, selected })}> ${name} </label>
          </div>`;
        })}
      </div>
    `;
  }

  private _handleChangeTab(name: string): void {
    this._selected = name;

    this.dispatchEvent(
      createEvent({
        type: "set_filter",
        data: {
          name: NAME,
          filter: { args: { tab: this._selected } },
        },
      }),
    );
  }

  private _ensureTabs() {
    if (typeof this.tabs === "string") {
      this.tabs = JSON.parse(this.tabs);
    }
  }

  private _ensureSelected() {
    if (!this._selected) {
      this._selected = this.tabs[0].name;
    }
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;
      align-items: center;

      padding-left: 2px;
      padding-bottom: 4px;
      gap: 8px;

      color: var(--canary-color-gray-50);
      text-decoration-color: var(--canary-color-gray-50);
    }

    .selected.tab {
      color: var(--canary-color-gray-10);
      text-decoration: underline;
      text-decoration-color: var(--canary-color-gray-10);
    }

    label {
      font-size: 0.75rem;
      text-decoration-skip-ink: none;
    }

    input {
      display: none;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryFilterTabsGlob;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
