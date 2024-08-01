import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { StringArray } from "../converters";
import { CalloutController } from "../controllers";

import { callout } from "../styles";

import "./canary-logo-cal";
import "./canary-hero-icon";

const NAME = "canary-callout-cal";

@customElement(NAME)
export class CanaryCalloutCal extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["meeting", "schedule", "cal.com", "calend"];

  @property({ type: String })
  url = "/";

  @property()
  message = "👋 Wanna schedule a call?";

  private _callout = new CalloutController(this);

  render() {
    return this._callout.render(
      () => html`
        <button @click=${this._handleClick}>
          <span>${this.message}</span>
          <div>
            <canary-logo-cal></canary-logo-cal>
            <canary-hero-icon name="arrow-up-right"></canary-hero-icon>
          </div>
        </button>
      `,
      { forceShow: this.forceShow, keywords: this.keywords },
    );
  }

  private _handleClick() {
    window.open(this.url, "_blank");
  }

  static styles = callout;
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCalloutCal;
  }
}
