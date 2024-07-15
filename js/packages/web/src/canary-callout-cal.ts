import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "./mixins";
import { callout } from "./styles";

import "./canary-logo-cal";
import "./canary-hero-icon";
import { StringArray } from "./converters";

@customElement("canary-callout-cal")
export class CanaryCalloutCal extends CalloutMixin(LitElement) {
  @property() message = "Wanna schedule a call?";

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["meeting", "schedule", "cal.com", "calend"];

  renderCallout() {
    return html`
      <button @click=${this._handleClick}>
        <span> 👋 ${this.message} </span>
        <div>
          <canary-logo-cal></canary-logo-cal>
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
