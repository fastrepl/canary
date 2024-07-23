import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext } from "./contexts";

import { input } from "./styles";
import "./canary-hero-icon";

const NAME = "canary-ask-input";

@customElement(NAME)
export class CanaryAskInput extends LitElement {
  @consume({ context: queryContext, subscribe: true })
  @property({ reflect: true })
  query = "";

  render() {
    return html`
      <div class="container">
        <canary-hero-icon name="question-mark-circle"></canary-hero-icon>
        <input
          type="text"
          value=${this.query}
          autocomplete="off"
          spellcheck="false"
          placeholder="Ask anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          autofocus
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        />
        <span>⏎</span>
      </div>
    `;
  }

  static styles = [
    input,
    css`
      span {
        font-size: 10px;
        font-family: var(--canary-font-family);
        color: var(--canary-color-gray-30);
      }
    `,
  ];

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    this.query = input.value;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Enter") {
      e.preventDefault();

      const event = new CustomEvent("input-change", {
        detail: this.query,
        bubbles: true,
        composed: true,
      });
      this.dispatchEvent(event);
    }

    if (e.key === "Tab") {
      e.preventDefault();

      const event = new CustomEvent("input-tab", {
        bubbles: true,
        composed: true,
      });
      this.dispatchEvent(event);
    }
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskInput;
  }
}
