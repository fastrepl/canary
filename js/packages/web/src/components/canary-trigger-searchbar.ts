import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-hero-icon";
import { KeyboardTriggerController } from "../controllers";

import type { TriggerShortcut } from "../types";

const NAME = "canary-trigger-searchbar";

@customElement(NAME)
export class CanaryTriggerSearchbar extends LitElement {
  @property({ type: String }) key: TriggerShortcut = "cmdk";

  render() {
    return html`
      <button aria-label="Search">
        <canary-hero-icon name="magnifying-glass"></canary-hero-icon>
        <span>Search</span>

        ${this.key === "cmdk"
          ? html`
              <kbd>
                <kbd class="meta">⌘</kbd>
                <kbd class="key">K</kbd>
              </kbd>
            `
          : html`
              <kbd>
                <kbd class="key">/</kbd>
              </kbd>
            `}
      </button>
    `;
  }

  constructor() {
    super();
    new KeyboardTriggerController(this, this.key);
  }

  static styles = css`
    :host {
      display: contents;
      width: fit-content;
    }

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

    @media (min-width: 50rem) {
      button {
        border: 1px solid var(--canary-color-gray-80);
        border-radius: 0.5rem;
        padding-inline-start: 0.75rem;
        padding-inline-end: 0.5rem;
        background-color: var(--canary-color-gray-100);
        color: var(--canary-color-gray-10);
        font-size: 0.875rem;
        width: 100%;
        max-width: 22rem;
      }
      button:hover {
        border-color: var(--canary-color-gray-60);
      }

      button > :last-child {
        margin-inline-start: auto;
      }
    }

    button > kbd {
      display: flex;
      flex-direction: row;
      align-items: center;

      display: none;
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

    span {
      display: none;
    }

    @media (min-width: 50rem) {
      span {
        display: inline;
      }

      button > kbd {
        display: flex;
      }
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryTriggerSearchbar;
  }
}
