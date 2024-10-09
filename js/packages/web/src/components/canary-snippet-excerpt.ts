import { LitElement, html, css, nothing } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { unsafeHTML } from "lit/directives/unsafe-html.js";

import { wrapper } from "../styles";

const NAME = "canary-snippet-excerpt";

@registerCustomElement(NAME)
export class CanarySnippetExcerpt extends LitElement {
  @property({ type: String }) value = "";

  private _maxLength = 110;

  render() {
    if (!this.value) {
      return nothing;
    }

    const content = this._strip(this._sanitize(this.value), this._maxLength);
    return html` <span class="excerpt">${unsafeHTML(content)}</span> `;
  }

  static styles = [
    wrapper,
    css`
      span {
        line-height: 1;
        white-space: nowrap;
        color: var(--canary-color-gray-20);
        font-size: 0.875rem;
        font-weight: normal;
        opacity: 0.8;
      }

      mark {
        border-radius: 2px;
        background-color: var(--canary-is-light, var(--canary-color-primary-30))
          var(--canary-is-dark, var(--canary-color-primary-20));
        color: var(--canary-color-gray-90);
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

  private _strip(html: string, maxLength: number) {
    const markRegex = /<mark>(.*?)<\/mark>/;
    const match = html.match(markRegex);

    if (!match) {
      return html.slice(0, maxLength);
    }

    const markIndex = match.index!;
    const markLength = match[0].length;

    const start = Math.max(
      0,
      markIndex - Math.floor((maxLength - markLength) / 2),
    );
    const end = Math.min(html.length, start + maxLength);

    return html.slice(start, end);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySnippetExcerpt;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
