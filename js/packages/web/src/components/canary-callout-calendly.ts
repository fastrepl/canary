import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "../mixins";
import { callout } from "../styles";

import "./canary-logo-calendly";
import "./canary-hero-icon";
import { StringArray } from "../converters";

const NAME = "canary-callout-calendly";

@customElement(NAME)
export class CanaryCalloutCalendly extends CalloutMixin(LitElement) {
  @property({ type: String }) url = "/";
  @property() message = "👋 Wanna schedule a call?";

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["meeting", "schedule", "calend"];

  renderCallout() {
    return html`
      <button @click=${this._handleClick}>
        <span>${this.message}</span>
        <div>
          <canary-logo-calendly></canary-logo-calendly>
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
    [NAME]: CanaryCalloutCalendly;
  }
}
