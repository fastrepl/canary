import { LitElement, html, css } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { modeContext } from "../contexts";

import type { ModeContext } from "../types";
import { createEvent } from "../store";

const NAME = "canary-mode-breadcrumb";

@customElement(NAME)
export class CanaryModeBreadcrumb extends LitElement {
  @property({ type: String })
  text = "";

  @consume({ context: modeContext, subscribe: true })
  @state()
  private _mode!: ModeContext;

  render() {
    return html`
      <div class="container">
        <button
          class="i-heroicons-chevron-left"
          @click=${this._handleClick}
        ></button>

        <div class="mode">
          <slot name="icon"> </slot>
          <span>${this.text}</span>
          <button
            class="i-heroicons-x-mark"
            @click=${this._handleClick}
          ></button>
        </div>
      </div>
    `;
  }

  private _handleClick() {
    const mode = this._mode.default ?? this._mode.options.values().next().value;
    this.dispatchEvent(createEvent({ type: "set_mode", data: mode }));
  }

  static styles = [
    css`
      @unocss-placeholder;
    `,
    css`
      div.container {
        display: flex;
        align-items: center;
        gap: 2px;
      }

      button {
        cursor: pointer;
      }

      div.mode {
        display: flex;
        align-items: center;

        margin-left: 2px;
        font-size: 0.75rem;

        padding: 2px 6px 2px 8px;
        border-radius: 8px;
        border: 1px solid var(--canary-is-light, var(--canary-color-gray-90))
          var(--canary-is-dark, var(--canary-color-gray-60));

        color: var(--canary-color-gray-20);
        background-color: var(--canary-color-gray-100);
      }

      span {
        white-space: nowrap;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryModeBreadcrumb;
  }
}
