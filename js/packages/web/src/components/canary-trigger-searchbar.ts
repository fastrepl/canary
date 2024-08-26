import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { KeyboardTriggerController } from "../controllers";
import type { TriggerShortcut } from "../types";
import { wrapper } from "../styles";

const NAME = "canary-trigger-searchbar";

@customElement(NAME)
export class CanaryTriggerSearchbar extends LitElement {
  @property({ type: String }) shortcut: TriggerShortcut = "cmdk";

  render() {
    return html`
      <button part="button" aria-label="Search">
        <div part="icon" class="icon i-heroicons-magnifying-glass"></div>
        <span part="text">Search</span>

        ${this.shortcut === "cmdk"
          ? html`
              <kbd part="kbd">
                <kbd class="meta">⌘</kbd>
                <kbd class="key">K</kbd>
              </kbd>
            `
          : html`
              <kbd part="kbd">
                <kbd class="key">/</kbd>
              </kbd>
            `}
      </button>
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
      :host {
        display: contents;
      }

      button {
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 0.5rem;
        font-size: 0.875rem;

        width: 100%;
        max-width: var(--canary-trigger-searchbar-max-width, 350px);
        height: var(--canary-trigger-searchbar-height, 40px);

        border: 1px solid var(--canary-color-gray-80);
        border-radius: 0.5rem;
        padding-inline-start: 0.75rem;
        padding-inline-end: 0.5rem;

        background-color: var(--canary-color-gray-100);
        color: var(--canary-color-gray-10);
      }
      button:hover {
        border-color: var(--canary-color-gray-60);
      }

      button > :last-child {
        margin-inline-start: auto;
      }

      button > kbd {
        display: flex;
        flex-direction: row;
        align-items: center;

        border-radius: 0.25rem;
        gap: 0.25em;
        padding: 0.2rem 0.35rem;

        color: var(--canary-color-gray-0);
        background-color: var(--canary-color-gray-95);
      }

      kbd.meta {
        font-size: 0.85rem;
      }
      kbd.key {
        font-size: 0.65rem;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTriggerSearchbar;
  }
}
