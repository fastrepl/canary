import { LitElement, html, nothing } from "lit";
import { state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { executionContext } from "../contexts";

import { registerCustomElement } from "../decorators";
import type { ExecutionContext } from "../types";

import "./canary-markdown";
import "./canary-ask-response";

const NAME = "canary-ask-results";

@registerCustomElement(NAME)
export class CanaryAskResults extends LitElement {
  @consume({ context: executionContext, subscribe: true })
  @state()
  private _execution?: ExecutionContext;

  render() {
    if (!this._execution?.ask) {
      return nothing;
    }

    return html`
      <div class="container" part="container">
        <canary-ask-response
          .response=${this._execution.ask}
        ></canary-ask-response>
      </div>
    `;
  }

  static styles = [];
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryAskResults;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
