import { LitElement, css, html } from "lit";
import { customElement, property } from "lit/decorators.js";

const NAME = "canary-icon-tree";

@customElement(NAME)
export class CanaryIconTree extends LitElement {
  @property({ type: Boolean })
  last = true;

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
          <path d="M8 6v21M20 27H8.3"></path>
          ${this.last ?? html`<path d="M8 6v42M20 27H8.3"></path>`}
        </g>
      </svg>
    `;
  }

  static styles = css`
    svg {
      color: var(--canary-color-gray-30);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryIconTree;
  }
}
