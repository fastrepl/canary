import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { customEvent } from "../events";
import { input } from "../styles";

const NAME = "canary-ask-input";

@customElement(NAME)
export class CanaryAskInput extends LitElement {
  @property({ reflect: true }) query = "";

  render() {
    return html`
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
    `;
  }

  static styles = [
    input,
    css`
      span {
        font-size: 10px;
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
      this.dispatchEvent(
        customEvent({ name: "input-change", data: this.query }),
      );
    }
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskInput;
  }
}
