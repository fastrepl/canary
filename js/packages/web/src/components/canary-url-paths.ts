import { LitElement, html, css, nothing } from "lit";
import { customElement, property } from "lit/decorators.js";

import { urlToParts } from "../utils";
import { global } from "../styles";

const NAME = "canary-url-paths";

@customElement(NAME)
export class CanaryURLPaths extends LitElement {
  @property({ type: String })
  url!: string;

  render() {
    const parts = urlToParts(this.url);

    if (parts.length == 0) {
      return this._render_url();
    } else {
      return this._render_parts(parts);
    }
  }

  private _render_parts(parts: string[]) {
    return html`<div class="paths">
      ${parts.map((part, i) =>
        i < parts.length - 1
          ? html`
              <span class="path">${part}</span>
              <span class="icon i-heroicons-chevron-right"></span>
            `
          : html`<span class="path">${part}</span>`,
      )}
    </div>`;
  }

  private _render_url() {
    let host = null;

    try {
      host = new URL(this.url).host;
    } catch (e) {
      host = null;
    }

    if (!host) {
      return nothing;
    }

    return html`<span class="path">${host}</span>`;
  }

  static styles = [
    global,
    css`
      @unocss-placeholder;
    `,
    css`
      .paths {
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 2px;
        margin-bottom: 2px;

        color: var(--canary-color-gray-30);
        font-size: 0.75rem;
      }

      .path {
        line-height: 1;
        max-width: 120px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    `,
  ];
}
