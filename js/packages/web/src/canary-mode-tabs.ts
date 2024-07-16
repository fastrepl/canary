import { LitElement, css, html, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { consume } from "@lit/context";
import { modeContext, defaultModeContext, type ModeContext } from "./contexts";

@customElement("canary-mode-tabs")
export class CanaryModeTabs extends LitElement {
  @consume({ context: modeContext, subscribe: true })
  @property({ attribute: false })
  mode: ModeContext = defaultModeContext;

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
    const event = new CustomEvent("set", { detail: option });
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
        border: 1px solid var(--canary-color-gray-6);

        display: flex;
        align-items: center;
        height: 14px;

        color: var(--canary-color-gray-3);
        background-color: var(--canary-color-black);
      }

      .tab:hover,
      .selected {
        color: var(--canary-color-white);
        background-color: var(--canary-color-gray-6);
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
