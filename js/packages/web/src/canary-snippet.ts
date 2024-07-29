import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { unsafeHTML } from "lit/directives/unsafe-html.js";

const NAME = "canary-snippet";

@customElement(NAME)
export class CanarySnippet extends LitElement {
  @property({ type: String }) value = "";

  private _maxLength = 110;

  render() {
    const content = this._strip(this.value, this._maxLength);
    return html` <span class="excerpt">${unsafeHTML(content)}</span> `;
  }

  static styles = css`
    span {
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;

      max-width: var(--canary-snippet-max-width, 400px);
      color: var(--canary-snippet-color, var(--canary-color-gray-20));
      font-size: var(--canary-snippet-font-size, 14px);
      font-weight: var(--canary-snippet-font-weight, normal);
    }

    mark {
      border-radius: 2px;
      background-color: var(--canary-is-light, var(--canary-color-primary-30))
        var(--canary-is-dark, var(--canary-color-primary-20));
      color: var(--canary-color-gray-90);
    }
  `;

  private _strip(excerpt: string, maxLength: number) {
    const markRegex = /<mark>(.*?)<\/mark>/;
    const match = excerpt.match(markRegex);

    if (!match) {
      return excerpt.slice(0, maxLength);
    }

    const markIndex = match.index!;
    const markLength = match[0].length;

    const start = Math.max(
      0,
      markIndex - Math.floor((maxLength - markLength) / 2),
    );
    const end = Math.min(excerpt.length, start + maxLength);

    return excerpt.slice(start, end);
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanarySnippet;
  }
}
