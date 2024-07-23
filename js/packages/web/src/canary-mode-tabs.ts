import { LitElement, css, html, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { consume } from "@lit/context";
import { modeContext } from "./contexts";
import type { ModeContext } from "./types";

const NAME = "canary-mode-tabs";

@customElement(NAME)
export class CanaryModeTabs extends LitElement {
  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode!: ModeContext;

  render() {
    return html`
      ${!this.mode.options || this.mode.options.size < 2
        ? nothing
        : html` <div class="tabs">
            ${Array.from(this.mode.options).map(
              (option, index) =>
                html`<div
                  class=${classMap({
                    tab: true,
                    selected: option === this.mode.current,
                    left: index === 0,
                    right: index === this.mode.options.size - 1,
                  })}
                  @click=${() => this._handleClick(option)}
                >
                  <input
                    type="radio"
                    name="mode"
                    .id=${option}
                    .value=${option}
                    ?checked=${option === this.mode.current}
                  />
                  <label>${option}</label>
                </div>`,
            )}
          </div>`}
    `;
  }

  private _handleClick(option: string) {
    const event = new CustomEvent("mode-set", {
      detail: option,
      bubbles: true,
      composed: true,
    });
    this.dispatchEvent(event);
  }

  static styles = [
    css`
      .tabs {
        display: flex;
        flex-direction: row;
      }

      .tab {
        cursor: pointer;
        font-family: var(--canary-font-family);
        font-size: 12px;

        padding: 4px 8px;
        font-size: 12px;
        border: 1px solid var(--canary-color-gray-90);

        display: flex;
        align-items: center;
        height: 14px;

        color: var(--canary-color-gray-40);
        background-color: var(--canary-color-gray-95);
      }

      .tab:hover,
      .selected {
        color: var(--canary-color-gray-0);
        background-color: var(--canary-color-gray-90);
      }

      input {
        display: none;
      }

      .left {
        border-radius: 8px 0 0 8px;
        border-right: none;
      }

      .right {
        border-radius: 0 8px 8px 0;
        border-left: none;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryModeTabs;
  }
}
