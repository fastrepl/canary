import { LitElement, html, css, nothing, type PropertyValues } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { unsafeHTML } from "lit/directives/unsafe-html.js";

import { urlToParts } from "./utils";
import "./canary-hero-icon";

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
      <a
        href=${this.url}
        class=${classMap({ container: true, selected: this.selected })}
      >
        <div class="content">
          ${this.depth()}
          <span class="title">${unsafeHTML(this.title)}</span>
          ${this.excerpt
            ? html`<span class="excerpt">${unsafeHTML(this.excerpt)}</span>`
            : nothing}
        </div>
        <div class=${classMap({ arrow: true, selected: this.selected })}>
          <canary-hero-icon name="chevron-right"></canary-hero-icon>
        </div>
      </a>
    `;
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
                    <canary-hero-icon name="chevron-right"></canary-hero-icon>
                  `
                : html`<span class="path">${part}</span>`,
            )}
          </div>`}
    `;
  }

  static styles = css`
    .container {
      cursor: pointer;

      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: space-between;

      padding: 8px 16px;
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
      opacity: 1;
    }

    .arrow {
      opacity: 0;
    }

    .content {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      gap: 2px;
    }

    .title {
      color: var(--canary-color-gray-10);
      font-size: 16px;
      font-weight: 500;

      max-width: 400px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .excerpt {
      color: var(--canary-color-gray-20);
      font-size: 14px;

      max-width: 400px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    mark {
      border-radius: 2px;
      background-color: var(--canary-is-light, var(--canary-color-primary-30))
        var(--canary-is-dark, var(--canary-color-primary-20));
      color: var(--canary-color-gray-90);
    }

    .paths {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 2px;

      color: var(--canary-color-gray-30);
      font-size: 13px;
    }

    .path {
      max-width: 120px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    a {
      text-decoration: none;
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryReference;
  }
}
