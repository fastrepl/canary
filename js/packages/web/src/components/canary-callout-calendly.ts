import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { StringArray } from "../converters";

import "./canary-logo-calendly";

const NAME = "canary-callout-calendly";

@customElement(NAME)
export class CanaryCalloutCalendly extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["meeting", "schedule", "calend"];

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
        <canary-logo-calendly slot="logo"></canary-logo-calendly>
      </canary-callout>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCalloutCalendly;
  }
}
