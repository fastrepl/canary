import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { provide } from "@lit/context";
import { providerContext, type ProviderContext } from "./contexts";

@customElement("canary-provider-cloud")
export class CanaryProviderCloud extends LitElement {
  @provide({ context: providerContext })
  @state()
  root: ProviderContext = { type: "cloud", endpoint: "", key: "" };

  @property() endpoint = "";
  @property() key = "";

  connectedCallback() {
    super.connectedCallback();
    if (this.root.type === "cloud") {
      this.root.key = this.key;
      this.root.endpoint = this.endpoint;
    }
  }

  render() {
    return html`<slot></slot>`;
  }
}
