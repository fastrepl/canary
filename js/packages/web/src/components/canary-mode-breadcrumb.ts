import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { customEvent } from "../events";

const NAME = "canary-mode-breadcrumb";

@customElement(NAME)
export class CanaryModeBreadcrumb extends LitElement {
  @property({ type: String }) text = "";
  @property({ type: String }) previous = "";

  render() {
    return html`
      <div class="container">
        <button
          class="icon i-heroicons-chevron-left"
          @click=${this._handleClick}
        ></button>

        <div class="mode">
          <slot name="icon"> </slot>
          <span>${this.text}</span>
          <button
            class="icon i-heroicons-x-mark"
            @click=${this._handleClick}
          ></button>
        </div>
      </div>
    `;
  }

  private _handleClick() {
    this.dispatchEvent(customEvent({ name: "mode-set", data: this.previous }));
  }

  static styles = [
    css`
      @unocss-placeholder;

      .icon {
        color: var(--canary-color-gray-20);
      }
    `,
    css`
      div.container {
        display: flex;
        align-items: center;
        gap: 4px;
      }

      button {
        cursor: pointer;
      }

      div.mode {
        display: flex;
        align-items: center;
        gap: 4px;

        margin-left: 2px;
        font-size: 12px;

        padding: 4px 8px;
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
