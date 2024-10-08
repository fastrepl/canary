import { LitElement, html } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { StringArray } from "../converters";

import "./canary-callout";
import "./canary-logo-cal";

const NAME = "canary-callout-cal";

@registerCustomElement(NAME)
export class CanaryCalloutCal extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["meeting", "schedule", "cal.com", "calend"];

  @property({ type: String })
  url = "/";

  @property()
  message = "👋 Wanna schedule a call?";

  render() {
    return html`
      <canary-callout
        .forceShow=${this.forceShow}
        .keywords=${this.keywords}
        .url=${this.url}
        .message=${this.message}
      >
        <canary-logo-cal slot="logo"></canary-logo-cal>
      </canary-callout>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCalloutCal;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
