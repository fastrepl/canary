import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

@customElement("canary-wrapper-starlight")
export class CanaryWrapperStarlight extends LitElement {
  render() {
    return html`<slot></slot>`;
  }

  static styles = css`
    :host {
      width: 100%;

      --canary-font-family: var(--sl-font-system, Arial, Helvetica, sans-serif);

      --canary-color-white: var(--sl-color-white);
      --canary-color-gray-1: var(--sl-color-gray-1);
      --canary-color-gray-2: var(--sl-color-gray-2);
      --canary-color-gray-3: var(--sl-color-gray-3);
      --canary-color-gray-4: var(--sl-color-gray-4);
      --canary-color-gray-5: var(--sl-color-gray-5);
      --canary-color-gray-6: var(--sl-color-gray-6);
      --canary-color-black: var(--sl-color-black);

      --canary-color-accent: var(--sl-color-accent);
      --canary-color-accent-low: var(--sl-color-accent-low);
      --canary-color-accent-high: var(--sl-color-accent-high);
    }
  `;
}
