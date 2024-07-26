import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "./mixins";
import { callout } from "./styles";

import "./canary-hero-icon";
import { StringArray } from "./converters";

const NAME = "canary-callout";

@customElement(NAME)
export class CanaryCallout extends CalloutMixin(LitElement) {
  @property() message = "";

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = [];

  renderCallout() {
    return html`
      <button @click=${this._handleClick}>
        <span> 👋 ${this.message} </span>
        <div>
          <slot name="logo"></slot>
          <canary-hero-icon name="arrow-up-right"></canary-hero-icon>
        </div>
      </button>
    `;
  }

  private _handleClick() {
    window.open(this.url, "_blank");
  }

  static styles = callout;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCallout;
  }
}
