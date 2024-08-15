import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";
import { ref, createRef } from "lit/directives/ref.js";

import { consume } from "@lit/context";
import { modeContext } from "../contexts";

import type { ModeContext } from "../types";
import { MODE_SEARCH } from "../constants";
import { global, scrollContainer } from "../styles";
import { createEvent } from "../store";

const NAME = "canary-search";

@customElement(NAME)
export class CanarySearch extends LitElement {
  readonly MODE = MODE_SEARCH;

  @consume({ context: modeContext, subscribe: true })
  @state()
  private _mode!: ModeContext;

  private _containerRef = createRef<HTMLElement>();

  connectedCallback() {
    super.connectedCallback();
    this.dispatchEvent(createEvent({ type: "register_mode", data: this.MODE }));
  }

  render() {
    return this._mode.current !== this.MODE
      ? nothing
      : html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input-before">
                <div class="icon i-heroicons-magnifying-glass"></div>
              </slot>
              <slot name="input"></slot>
              <slot name="input-after"></slot>
            </div>
            <div class="scroll-container" ${ref(this._containerRef)}>
              <div class="body">
                <slot name="body"></slot>
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
        padding: 1px 12px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
}
