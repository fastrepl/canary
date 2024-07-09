import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./icons/question-mark-circle";

@customElement("canary-input-ask")
export class CanaryInputAsk extends LitElement {
  @property() query = "";

  render() {
    return html`
      <div class="container">
        <div class="icon">
          <hero-question-mark-circle></hero-question-mark-circle>
        </div>
        <input
          type="text"
          autocomplete="off"
          autofocus
          placeholder="Ask anything..."
          @input=${this._handleInput}
          @keydown=${this._handleKeyDown}
        />
      </div>
    `;
  }

  static styles = css`
    .container {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .icon {
      width: 1rem;
      height: 1rem;
    }

    input {
      width: 60vw;
      max-width: 600px;
      height: 30px;
      outline: none;
      border: none;
      font-size: 16px;
    }

    input::placeholder {
      color: #9f9f9f;
      font-size: 14px;
    }
  `;

  private _handleInput(e: KeyboardEvent) {
    const input = e.target as HTMLInputElement;
    this.query = input.value;
  }

  private _handleKeyDown(e: KeyboardEvent) {
    if (e.key === "Enter") {
      e.preventDefault();
      const event = new CustomEvent("change", { detail: this.query });
      this.dispatchEvent(event);
    }

    if (e.key === "Tab") {
      e.preventDefault();
      const event = new CustomEvent("tab");
      this.dispatchEvent(event);
    }
  }
}
