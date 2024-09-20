import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { unsafeHTML } from "lit/directives/unsafe-html.js";

import { wrapper } from "../styles";

const NAME = "canary-snippet-title";

@customElement(NAME)
export class CanarySnippetTitle extends LitElement {
  @property({ type: String }) value = "";

  render() {
    return html`
      <span class="title">${unsafeHTML(this._sanitize(this.value))}</span>
    `;
  }

  static styles = [
    wrapper,
    css`
      span {
        color: var(--canary-color-gray-20);
        font-size: 0.875rem;
        font-weight: normal;
        line-height: 1;

        white-space: nowrap;
        max-width: 300px;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      mark {
        background-color: transparent;
        color: inherit;
      }
    `,
  ];

  private _sanitize(html: string) {
    return html
      .replace(/<mark>/g, "__MARK_START__")
      .replace(/<\/mark>/g, "__MARK_END__")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/__MARK_START__/g, "<mark>")
      .replace(/__MARK_END__/g, "</mark>");
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySnippetTitle;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
