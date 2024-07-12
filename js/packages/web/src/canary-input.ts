import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./icons/question-mark-circle";
import "./icons/magnifying-glass";

const STYLE = css`
  .container {
    display: flex;
    align-items: center;
    gap: 8px;
    border-radius: 8px;
    color: var(--canary-color-gray-1);
    background-color: var(--canary-color-gray-6);
  }

  .icon {
    width: 1rem;
    height: 1rem;
  }

  input {
    width: 400px;
    height: 30px;
    outline: none;
    border: none;
    font-size: 16px;
    color: var(--canary-color-gray-1);
    background-color: var(--canary-color-gray-6);
  }

  input::placeholder {
    color: var(--canary-color-gray-3);
    font-size: 14px;
  }
`;

@customElement("canary-input-search")
export class CanaryInputSearch extends LitElement {
  @property() value = "";

  render() {
    return html`
      <div class="container">
        <div class="icon">
          <hero-magnifying-glass></hero-magnifying-glass>
        </div>
        <input
          type="text"
          value=${this.value}
          autocomplete="off"
          placeholder="Search for anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          autofocus
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        />
      </div>
    `;
  }

  static styles = STYLE;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    const event = new CustomEvent("change", { detail: input.value });
    this.dispatchEvent(event);
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Tab") {
      e.preventDefault();
      const event = new CustomEvent("toggle", { detail: "Ask" });
      this.dispatchEvent(event);
    }
  }
}

@customElement("canary-input-ask")
export class CanaryInputAsk extends LitElement {
  @property() value = "";

  render() {
    return html`
      <div class="container">
        <div class="icon">
          <hero-question-mark-circle></hero-question-mark-circle>
        </div>
        <input
          type="text"
          value=${this.value}
          autocomplete="off"
          placeholder="Ask anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
          autofocus
          onfocus="this.setSelectionRange(this.value.length,this.value.length);"
        />
      </div>
    `;
  }

  static styles = STYLE;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    this.value = input.value;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Enter") {
      e.preventDefault();
      const event = new CustomEvent("change", { detail: this.value });
      this.dispatchEvent(event);

      this.value = "";
      (e.target as HTMLInputElement).value = "";
    }

    if (e.key === "Tab") {
      e.preventDefault();
      const event = new CustomEvent("toggle", { detail: "Search" });
      this.dispatchEvent(event);
    }
  }
}
