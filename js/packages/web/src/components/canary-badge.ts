import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { wrapper } from "../styles";

const NAME = "canary-badge";

@customElement(NAME)
export class CanaryBadge extends LitElement {
  @property({ type: String })
  name!: string;

  render() {
    return html` <span class="container"> ${this.name} </span> `;
  }

  static styles = [
    wrapper,
    css`
      .container {
        padding: 2px 4px;
        border-radius: 2px;
        font-size: 0.625rem;
        border: 1px solid var(--canary-color-primary-30);
        color: var(--canary-color-primary-30);
      }
    `,
  ];
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
