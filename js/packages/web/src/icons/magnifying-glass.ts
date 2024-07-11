import { LitElement, html } from "lit";
import { customElement } from "lit/decorators.js";

@customElement("hero-magnifying-glass")
export class HeroIconMagnifyingGlass extends LitElement {
  render() {
    return html`${this.svg()}`;
  }

  svg() {
    return html`
      <!-- prettier-ignore -->
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
        <path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z" />
      </svg>
    `;
  }
}
