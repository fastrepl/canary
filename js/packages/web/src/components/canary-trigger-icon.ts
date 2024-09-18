import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { TriggerShortcut } from "../types";
import { KeyboardTriggerController } from "../controllers";
import { wrapper } from "../styles";

const NAME = "canary-trigger-icon";

@customElement(NAME)
export class CanaryTriggerIcon extends LitElement {
  @property({ type: String }) shortcut: TriggerShortcut = "cmdk";

  render() {
    return html`
      <button
        aria-label="Search"
        class="icon i-heroicons-magnifying-glass"
      ></button>
    `;
  }

  constructor() {
    super();
    new KeyboardTriggerController(this, this.shortcut);
  }

  static styles = [
    wrapper,
    css`
      @unocss-placeholder;
    `,
    css`
      button {
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        border: 0;
        height: 2.5rem;
        font-size: 1.25rem;
        background-color: transparent;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTriggerIcon;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
