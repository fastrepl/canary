import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "./mixins";
import "./canary-discord-logo";

@customElement("canary-callout-discord")
export class CanaryCalloutSlack extends CalloutMixin(LitElement) {
  @property() url = "";
  @property({ type: Array }) keywords: string[] = [
    "discord",
    "help",
    "support",
    "community",
  ];

  renderCallout() {
    return html`
      <div>
        <a href=${this.url} target="_blank">Discord</a>
      </div>
    `;
  }

  static styles = css``;
}
