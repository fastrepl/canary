import { LitElement, html, css } from "lit";
import { customElement } from "lit/decorators.js";

@customElement("canary-wrapper-docusaurus")
export class CanaryWrapperDocusaurus extends LitElement {
  render() {
    return html`<slot></slot>`;
  }

  static styles = css`
    :host {
      --canary-font-family: var(
        --ifm-font-family-base,
        Arial,
        Helvetica,
        sans-serif
      );

      --canary-color-white: var(--ifm-color-white);
      --canary-color-gray-1: var(--ifm-color-gray-100);
      --canary-color-gray-2: var(--ifm-color-gray-200);
      --canary-color-gray-3: var(--ifm-color-gray-300);
      --canary-color-gray-4: var(--ifm-color-gray-400);
      --canary-color-gray-5: var(--ifm-color-gray-600);
      --canary-color-gray-6: var(--ifm-color-gray-800);
      --canary-color-black: var(--ifm-color-black);

      --canary-color-accent: var(--ifm-color-primary);
    }

    :host([data-theme="dark"]) {
      --canary-color-accent-low: var(--ifm-color-primary-darker);
      --canary-color-accent-high: var(--ifm-color-primary-lighter);
    }

    :host([data-theme="dark"]) {
      --canary-color-accent-low: var(--ifm-color-primary-lighter);
      --canary-color-accent-high: var(--ifm-color-primary-darker);
    }
  `;
}
