import { LitElement, html, css, nothing, type PropertyValues } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { urlToParts } from "../utils";
import { customEvent } from "../events";

import "./canary-snippet";

const NAME = "canary-reference";

@customElement(NAME)
export class CanaryReference extends LitElement {
  @property() url = "";
  @property() title = "";
  @property() excerpt: string | undefined = undefined;
  @property({ type: Boolean }) selected = false;

  updated(changed: PropertyValues<this>) {
    if (changed.get("selected")) {
      this.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  render() {
    return html`
      <button
        @click=${this._handleClick}
        class=${classMap({ container: true, selected: this.selected })}
      >
        <div class="content">
          ${this.depth()}
          <canary-snippet class="title" .value=${this.title}></canary-snippet>
          ${this.excerpt
            ? html`<canary-snippet class="excerpt" .value=${this.excerpt}>
              </canary-snippet>`
            : nothing}
        </div>
        <div class=${classMap({ arrow: true, selected: this.selected })}>
          <div class="icon i-heroicons-chevron-right"></div>
        </div>
      </button>
    `;
  }

  private _handleClick() {
    this.dispatchEvent(customEvent({ name: "modal-close" }));
    window.location.href = this.url;
  }

  depth() {
    const parts = urlToParts(this.url);

    return html`
      ${parts.length == 0
        ? nothing
        : html`<div class="paths">
            ${parts.map((part, i) =>
              i < parts.length - 1
                ? html`
                    <span class="path">${part}</span>
                    <div class="icon i-heroicons-chevron-right"></div>
                  `
                : html`<span class="path">${part}</span>`,
            )}
          </div>`}
    `;
  }

  static styles = [
    css`
      @unocss-placeholder;

      .icon {
        color: var(--canary-color-gray-20);
      }
    `,
    css`
      .container {
        position: relative;
        cursor: pointer;
        overflow: hidden;

        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;

        padding: 8px 12px;
        border: 1px solid var(--canary-color-gray-90);
        border-radius: 8px;
        background-color: var(--canary-is-light, var(--canary-color-gray-95))
          var(--canary-is-dark, var(--canary-color-gray-80));
      }

      .container:hover,
      .selected {
        background-color: var(--canary-is-light, var(--canary-color-primary-95))
          var(--canary-is-dark, var(--canary-color-primary-70));
      }

      .selected .arrow,
      .container:hover .arrow {
        opacity: 0.5;
      }

      .arrow {
        position: absolute;
        top: 45%;
        right: 8px;
        opacity: 0;
      }

      .content {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        gap: 3px;

        overflow: hidden;
        text-overflow: ellipsis;
        max-width: calc(100% - 20px);
      }

      .paths {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 2px;
        margin-bottom: 2px;

        color: var(--canary-color-gray-30);
        font-size: 13px;
      }

      .path {
        max-width: 120px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }

      button {
        cursor: pointer;
        width: 100%;
      }

      .title {
        --canary-snippet-color: var(--canary-color-gray-10);
        --canary-snippet-font-size: 16px;
        --canary-snippet-font-weight: 500;
      }

      .excerpt {
        --canary-snippet-color: var(--canary-color-gray-20);
        --canary-snippet-font-size: 14px;
        --canary-snippet-font-weight: 400;
      }
    `,
  ];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryReference;
  }
}
