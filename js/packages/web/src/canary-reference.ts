import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import "./canary-hero-icon";

@customElement("canary-reference")
export class CanaryReference extends LitElement {
  @property() url = "";
  @property() title = "";

  render() {
    return html`
      <div class="container" @click=${this._handleClick}>
        <div class="content">
          ${this.depth()}
          <span class="title">${this.title} </span>
        </div>
        <div class="arrow">
          <canary-hero-icon name="arrow-up-right"></canary-hero-icon>
        </div>
      </div>
    `;
  }

  depth() {
    const paths = new URL(this.url).pathname.split("/");
    const parts = paths
      .map((path, _) => {
        const text = path.split("-").join(" ");
        return text.charAt(0).toUpperCase() + text.slice(1);
      })
      .slice(-4);

    return html`
      <div class="paths">
        ${parts.map((part, i) =>
          i < parts.length - 1
            ? html`
                <span class="path">${part}</span>
                <canary-hero-icon name="chevron-right"></canary-hero-icon>
              `
            : html`<span class="path">${part}</span>`,
        )}
      </div>
    `;
  }

  private _handleClick() {
    window.open(this.url, "_blank");
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: space-between;

      padding: 8px 20px;
      border: 1px solid var(--canary-color-gray-5);
      border-radius: 8px;
      background-color: var(--canary-color-black);

      cursor: pointer;
    }

    .container:hover {
      background-color: var(--canary-color-accent-low);
    }

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
      color: var(--canary-color-gray-1);
      font-size: 14px;

      max-width: 400px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }

    .paths {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 2px;

      font-weight: lighter;
      color: var(--canary-color-gray-3);
      font-size: 12px;
    }

    .path {
      max-width: 120px;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  `;
}
