import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

const NAME = "canary-badge";

@customElement(NAME)
export class CanaryBadge extends LitElement {
  @property({ type: String })
  name!: string;

  render() {
    return html` <span class="container"> ${this.name} </span> `;
  }

  static styles = css`
    .container {
      padding: 0.25em 0.4em;
      border-radius: 0.25em;
      font-size: 0.75rem;
      border: 1px solid var(--canary-color-primary-60);
      color: var(--canary-color-primary-60);
    }
  `;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryBadge;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
