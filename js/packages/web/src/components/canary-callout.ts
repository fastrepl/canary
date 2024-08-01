import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { StringArray } from "../converters";
import { CalloutController } from "../controllers";

import { callout } from "../styles";
import "./canary-hero-icon";

const NAME = "canary-callout";

@customElement(NAME)
export class CanaryCallout extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = [];

  @property({ type: String })
  url = "/";
  @property()
  message = "";

  private _callout = new CalloutController(this);

  renderCallout() {
    return this._callout.render(
      () => html`
        <button @click=${this._handleClick}>
          <span> 👋 ${this.message} </span>
          <div>
            <slot name="logo"></slot>
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
    [NAME]: CanaryCallout;
  }
}
