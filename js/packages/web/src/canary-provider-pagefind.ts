import { LitElement, html } from "lit";
import { customElement, state } from "lit/decorators.js";

import { provide } from "@lit/context";
import { providerContext, type ProviderContext } from "./contexts";

@customElement("canary-provider-pagefind")
export class CanaryProviderPagefind extends LitElement {
  @provide({ context: providerContext })
  @state()
  root: ProviderContext = { type: "pagefind" };

  connectedCallback() {
    super.connectedCallback();
    throw new Error("Not implemented yet");
  }

  render() {
    return html`<slot></slot>`;
  }
}
