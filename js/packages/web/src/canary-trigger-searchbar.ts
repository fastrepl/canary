import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-hero-icon";

const NAME = "canary-trigger-searchbar";

@customElement(NAME)
export class CanaryTriggerSearchbar extends LitElement {
  @property({ type: String }) key: "cmdk" | "slash" = "cmdk";

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

  connectedCallback() {
    super.connectedCallback();
    document.addEventListener("keydown", this._handleShortcut);
  }

  disconnectedCallback() {
    document.removeEventListener("keydown", this._handleShortcut);
    super.disconnectedCallback();
  }

  private _handleShortcut(e: KeyboardEvent) {
    if (this._isShortcut(e)) {
      e.preventDefault();

      this.dispatchEvent(
        new MouseEvent("click", {
          bubbles: true,
          cancelable: true,
        }),
      );
    }
  }

  private _isShortcut(e: KeyboardEvent) {
    if (this.key === "cmdk") {
      return e.key === "k" && (e.metaKey || e.ctrlKey);
    }

    if (this.key === "slash") {
      return e.key === "/";
    }
  }

  static styles = css`
    button {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      border: 0;
      background-color: transparent;
      color: var(--canary-color-gray-1);
      cursor: pointer;
      height: 2.5rem;
      font-size: 1.25rem;
    }

    @media (min-width: 50rem) {
      button {
        border: 1px solid var(--canary-color-gray-5);
        border-radius: 0.5rem;
        padding-inline-start: 0.75rem;
        padding-inline-end: 0.5rem;
        background-color: var(--canary-color-black);
        color: var(--canary-color-gray-2);
        font-size: 0.875rem;
        width: 100%;
        max-width: 22rem;
      }
      button:hover {
        border-color: var(--canary-color-gray-2);
        color: var(--canary-color-white);
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
      background-color: var(--canary-color-gray-6);
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
