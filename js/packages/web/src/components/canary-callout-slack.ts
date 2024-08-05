import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import { StringArray } from "../converters";

import "./canary-callout";
import "./canary-logo-slack";

const NAME = "canary-callout-slack";

@customElement(NAME)
export class CanaryCalloutSlack extends LitElement {
  @property({ type: Boolean })
  forceShow = true;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["slack", "help", "support", "community"];

  @property({ type: String })
  url = "/";

  @property()
  message = "👋 Looking for help?";

  render() {
    return html`
      <canary-callout
        .forceShow=${this.forceShow}
        .keywords=${this.keywords}
        .url=${this.url}
        .message=${this.message}
      >
        <canary-logo-slack slot="logo"></canary-logo-slack>
      </canary-callout>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCalloutSlack;
  }
}
