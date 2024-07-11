import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

@customElement("canary-toggle")
export class CanaryToggle extends LitElement {
  @property({ type: String }) left = "";
  @property({ type: String }) right = "";
  @property({ type: String }) selected = "";

  render() {
    return html`
      <div class="container">
        <button
          class=${classMap({
            tab: true,
            left: true,
            selected: this.left === this.selected,
          })}
          @click=${() => this._handleClick(this.left)}
        >
          ${this.left}
        </button>
        <button
          class=${classMap({
            tab: true,
            right: true,
            selected: this.right === this.selected,
          })}
          @click=${() => this._handleClick(this.right)}
        >
          ${this.right}
        </button>
      </div>
    `;
  }

  private _handleClick(tab: string) {
    const event = new CustomEvent("toggle", { detail: tab });
    this.dispatchEvent(event);
  }

  static styles = [
    css`
      .container {
        display: flex;
        flex-direction: row;
      }

      .tab {
        padding: 4px 8px;
        font-size: 12px;
        border: 1px solid var(--canary-color-gray-4);

        color: var(--canary-color-gray-1);
        background-color: var(--canary-color-gray-6);
      }

      .left {
        border-radius: 8px 0 0 8px;
        border-right: none;
      }

      .right {
        border-radius: 0 8px 8px 0;
        border-left: none;
      }

      .left:hover,
      .right:hover,
      .selected {
        color: var(--canary-color-gray-6);
        background-color: var(--canary-color-gray-1);
      }
    `,
  ];
}
