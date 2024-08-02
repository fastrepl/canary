import { consume } from "@lit/context";
import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { modeContext } from "../contexts";
import type { ModeContext } from "../types";
import { MODE_ASK } from "../constants";

import "./canary-mode-tabs";
import "./canary-hero-icon";

const NAME = "canary-ask";

@customElement(NAME)
export class CanaryAsk extends LitElement {
  readonly MODE = MODE_ASK;

  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  connectedCallback() {
    super.connectedCallback();

    this.dispatchEvent(
      new CustomEvent("register-mode", {
        bubbles: true,
        composed: true,
        detail: this.MODE,
      }),
    );
  }

  render() {
    return this.mode?.current !== this.MODE
      ? nothing
      : html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input-before">
                <canary-hero-icon name="chat-bubble-left"></canary-hero-icon>
              </slot>
              <slot name="input"></slot>
              <slot name="input-after"></slot>
            </div>
            <slot name="results"></slot>
          </div>
        `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
    }

    .input-wrapper {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 4px;
      padding: 1px 6px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAsk;
  }
}
