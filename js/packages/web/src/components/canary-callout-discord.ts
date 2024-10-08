import { LitElement, html } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { StringArray } from "../converters";

import "./canary-callout";
import "./canary-logo-discord";

const NAME = "canary-callout-discord";

@registerCustomElement(NAME)
export class CanaryCalloutDiscord extends LitElement {
  @property({ type: Boolean })
  forceShow = false;

  @property({ reflect: true, converter: StringArray })
  keywords: string[] = ["discord", "help", "support", "community"];

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
        <canary-logo-discord slot="logo"></canary-logo-discord>
      </canary-callout>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryCalloutDiscord;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
