import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";
import { ref, createRef } from "lit/directives/ref.js";

import { consume } from "@lit/context";
import { modeContext } from "../contexts";

import type { ModeContext } from "../types";
import { MODE_ASK } from "../constants";
import { createEvent } from "../store";
import { global, scrollContainer } from "../styles";

import "./canary-mode-tabs";

const NAME = "canary-ask";

@customElement(NAME)
export class CanaryAsk extends LitElement {
  readonly MODE = MODE_ASK;

  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  private _containerRef = createRef<HTMLElement>();

  connectedCallback() {
    super.connectedCallback();
    this.dispatchEvent(createEvent({ type: "register_mode", data: this.MODE }));
  }

  render() {
    return this.mode?.current !== this.MODE
      ? nothing
      : html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input-before">
                <div class="icon i-heroicons-chat-bubble-left"></div>
              </slot>
              <slot name="input"></slot>
              <slot name="input-after"></slot>
            </div>
            <div class="scroll-container" ${ref(this._containerRef)}>
              <div class="results">
                <slot name="result"></slot>
              </div>
            </div>
          </div>
        `;
  }

  static styles = [
    global,
    scrollContainer,
    css`
      @unocss-placeholder;
    `,
    css`
      .container {
        display: flex;
        flex-direction: column;
      }

      .input-wrapper {
        display: flex;
        align-items: center;
        gap: 8px;
        margin-bottom: 4px;
        padding: 1px 12px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAsk;
  }
}
