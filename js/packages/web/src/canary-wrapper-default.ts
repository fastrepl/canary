import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

@customElement("canary-wrapper-default")
export class CanaryWrapperDefault extends LitElement {
  @property() theme = "light";

  render() {
    return html`<div data-theme=${this.theme}>
      <slot></slot>
    </div>`;
  }

  static styles = css`
    :host {
      --canary-font-family: Arial, Helvetica, sans-serif;
    }

    div[data-theme="light"] {
      --canary-color-accent-low: #c0e2b8;
      --canary-color-accent: #258100;
      --canary-color-accent-high: #0d3e00;
      --canary-color-white: #151a13;
      --canary-color-gray-1: #1f2a1c;
      --canary-color-gray-2: #303c2d;
      --canary-color-gray-3: #4f5c4d;
      --canary-color-gray-4: #82907f;
      --canary-color-gray-5: #bdc4bb;
      --canary-color-gray-6: #eaf0e8;
      --canary-color-gray-7: #f4f7f3;
      --canary-color-black: #ffffff;
    }

    div[data-theme="dark"] {
      --canary-color-accent-low: #072d00;
      --canary-color-accent: #247f00;
      --canary-color-accent-high: #aad7a0;
      --canary-color-white: #ffffff;
      --canary-color-gray-1: #eaf0e8;
      --canary-color-gray-2: #bdc4bb;
      --canary-color-gray-3: #82907f;
      --canary-color-gray-4: #4f5c4d;
      --canary-color-gray-5: #303c2d;
      --canary-color-gray-6: #1f2a1c;
      --canary-color-black: #151a13;
    }
  `;
}
