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
        border: 1px solid #e3e3e3;
        color: #616161;
        font-size: 12px;
      }

      .left {
        border-radius: 8px 0 0 8px;
        border-right: none;
      }
      .left:hover {
        background-color: var(--canary-brand);
        border-color: var(--canary-brand-border);
      }

      .right {
        border-radius: 0 8px 8px 0;
        border-left: none;
      }
      .right:hover {
        background-color: var(--canary-brand);
        border-color: var(--canary-brand-border);
      }

      .selected {
        background-color: var(--canary-brand);
      }
    `,
  ];
}
