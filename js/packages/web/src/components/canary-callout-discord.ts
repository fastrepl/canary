import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "../mixins";
import { callout } from "../styles";

import "./canary-logo-discord";
import "./canary-hero-icon";
import { StringArray } from "../converters";

const NAME = "canary-callout-discord";

@customElement(NAME)
export class CanaryCalloutDiscord extends CalloutMixin(LitElement) {
  @property({ type: String }) url = "/";
  @property() message = "👋 Looking for help?";

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["discord", "help", "support", "community"];

  renderCallout() {
    return html`
      <button @click=${this._handleClick}>
        <span>${this.message}</span>
        <div>
          <canary-logo-discord></canary-logo-discord>
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
    [NAME]: CanaryCalloutDiscord;
  }
}
