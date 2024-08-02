import { consume } from "@lit/context";
import { LitElement, html, css, nothing } from "lit";
import { customElement, state } from "lit/decorators.js";

import { modeContext } from "../contexts";
import type { ModeContext } from "../types";
import { MODE_SEARCH } from "../constants";

import "./canary-mode-tabs";
import "./canary-search-empty";
import "./canary-hero-icon";

const NAME = "canary-search";

@customElement(NAME)
export class CanarySearch extends LitElement {
  readonly MODE = MODE_SEARCH;

  @consume({ context: modeContext, subscribe: true })
  @state()
  mode!: ModeContext;

  @state() empty = false;

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
    return this.mode.current !== this.MODE
      ? nothing
      : html`
          <div class="container">
            <div class="input-wrapper">
              <slot name="input-before">
                <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
              </slot>
              <slot name="input"></slot>
              <slot name="input-after"></slot>
            </div>
            <div class="body">
              <div class="callouts">
                <slot name="callout"></slot>
              </div>
              <slot name="results" @empty=${this._handleEmpty}></slot>
              ${this.empty
                ? html`<slot name="empty">
                    <canary-search-empty></canary-search-empty>
                  </slot>`
                : nothing}
            </div>
          </div>
        `;
  }

  private _handleEmpty(e: CustomEvent) {
    this.empty = e.detail;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: column;
    }

    .input-wrapper {
      display: flex;
      align-items: center;
      gap: 4px;
      margin-bottom: 4px;
      padding: 1px 6px;
    }

    .callouts {
      display: flex;
      flex-direction: column;
    }

    .body {
      padding-left: 4px;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySearch;
  }
}
