import { LitElement, css, html, svg } from "lit";
import { customElement, property } from "lit/decorators.js";

const NAME = "canary-icon-tree";

@customElement(NAME)
export class CanaryIconTree extends LitElement {
  @property({ type: Boolean })
  last = false;

  render() {
    // https://github.com/algolia/docsearch/blob/3067715/packages/docsearch-react/src/ResultsScreen.tsx#L33
    return html`
      <svg viewBox="0 0 24 54">
        <g
          stroke="currentColor"
          fill="none"
          fillRule="evenodd"
          strokeLinecap="round"
          strokeLinejoin="round"
        >
          ${this._paths()}
        </g>
      </svg>
    `;
  }

  private _paths() {
    return this.last
      ? svg`<path d="M8 6v21M20 27H8.3"></path>`
      : svg`<path d="M8 6v21M20 27H8.3"></path>
      <path d="M8 6v42M20 27H8.3"></path>`;
  }

  static styles = css`
    :host {
      display: contents;
    }

    svg {
      width: 1.4em;
      color: var(--canary-is-light, var(--canary-color-gray-80))
        var(--canary-is-dark, var(--canary-color-gray-50));
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryIconTree;
  }
}
