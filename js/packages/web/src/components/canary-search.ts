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
            <div class="head">
              <slot name="head"></slot>
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

      .head {
        position: sticky;
        top: 0px;
        background-color: var(--canary-color-gray-100);
        z-index: 50;
        padding-left: 12px;
        margin-bottom: 4px;
      }

      .body {
        display: flex;
        flex-direction: column;
        gap: 4px;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
