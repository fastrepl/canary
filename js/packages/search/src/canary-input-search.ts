import { LitElement, css, html } from "lit";
import { customElement } from "lit/decorators.js";

import "./icons/magnifying-glass";

@customElement("canary-input-search")
export class CanaryInputSearch extends LitElement {
  render() {
    return html`
      <div class="container">
        <div class="icon">
          <hero-magnifying-glass></hero-magnifying-glass>
        </div>
        <input
          type="text"
          autocomplete="off"
          autofocus
          placeholder="Search for anything..."
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
