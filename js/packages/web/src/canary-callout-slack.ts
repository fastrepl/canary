import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "./mixins";
import { callout } from "./styles";

import "./canary-logo-slack";
import "./canary-hero-icon";

@customElement("canary-callout-slack")
export class CanaryCalloutSlack extends CalloutMixin(LitElement) {
  @property() message = "Looking for help?";

  @property({ type: Array }) keywords: string[] = [
    "slack",
    "help",
    "support",
    "community",
  ];

  renderCallout() {
    return html`
      <button @click=${this._handleClick}>
        <span> 👋 ${this.message} </span>
        <div>
          <canary-logo-slack url=${this.url}></canary-logo-slack>
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
