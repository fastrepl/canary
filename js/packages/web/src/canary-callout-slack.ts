import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";

import { CalloutMixin } from "./mixins";
import "./canary-slack-logo";

@customElement("canary-callout-slack")
export class CanaryCalloutSlack extends CalloutMixin(LitElement) {
  @property() url = "";
  @property({ type: Array }) keywords: string[] = [
    "slack",
    "help",
    "support",
    "community",
  ];

  renderCallout() {
    return html`
      <div>
        <a href=${this.url} target="_blank">Slack</a>
      </div>
    `;
  }

  static styles = css``;
}
