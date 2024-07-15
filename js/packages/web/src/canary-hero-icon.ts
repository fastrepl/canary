import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { unsafeSVG } from "lit/directives/unsafe-svg.js";

const ICONS: Record<string, string> = {
  "magnifying-glass": `<path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />`,
  "question-mark-circle": `<path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z" />`,
  "chevron-right": `<path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5" />`,
  "arrow-up-right": `<path stroke-linecap="round" stroke-linejoin="round" d="m4.5 19.5 15-15m0 0H8.25m11.25 0v11.25" />`,
  "exclamation-triangle": `<path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" />`,
};

@customElement("canary-hero-icon")
export class CanaryHeroIcon extends LitElement {
  @property() name = "";

  render() {
    return html`
      <svg
        fill="none"
        viewBox="0 0 24 24"
        stroke-width="1.5"
        stroke="currentColor"
      >
        ${unsafeSVG(ICONS[this.name])}
      </svg>
    `;
  }

  static styles = css`
    svg {
      width: 1em;
      height: 1em;
      padding-top: 0.3em;

      color: var(--canary-color-gray-4);
    }
  `;
}
