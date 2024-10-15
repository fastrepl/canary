import { LitElement, html } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { parse as safeParse } from "best-effort-json-parser";

import type { AskFunction, SearchFunction } from "../types";

import { wrapper } from "../styles";
import { createEvent } from "../store";
import { cache } from "../decorators/cache";
import { sseIterator } from "../utils";

const NAME = "canary-provider-cloud";

@registerCustomElement(NAME)
export class CanaryProviderCloud extends LitElement {
  @property({ type: String, attribute: "api-base" })
  apiBase = "https://cloud.getcanary.dev";

  /**
   * @deprecated use `project-key` instead
   */
  @property({ type: String, attribute: "api-key" })
  apiKey = "";

  @property({ type: String, attribute: "project-key" })
  projectKey = "";

  connectedCallback() {
    super.connectedCallback();

    if (!this.apiKey && !this.projectKey) {
      throw new Error("project-key or api-key is required");
    }

    this._dispatchOperations();
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  private _dispatchOperations() {
    this.dispatchEvent(
      createEvent({
        type: "register_operations",
        data: {
          search: cache(this.search),
          ask: this.ask,
        },
      }),
    );
  }

  private _meta() {
    return {
      version: __VERSION__,
    };
  }

  search: SearchFunction = async (query, meta, signal) => {
    const params = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.projectKey || this.apiKey}`,
      },
      body: JSON.stringify({ query, meta: { ...meta, ...this._meta() } }),
      signal,
    };

    const res = await fetch(`${this.apiBase}/api/v1/search`, params);
    if (!res.ok) {
      throw new Error(res.statusText);
    }

    return res.json();
  };

  ask: AskFunction = async (query, meta, handleDelta, signal) => {
    const url = `${this.apiBase}/api/v1/ask`;
    const req = new Request(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.projectKey || this.apiKey}`,
      },
      body: JSON.stringify({ query, meta: { ...meta, ...this._meta() } }),
      signal,
    });

    let buffer = "";

    for await (const { data } of sseIterator(req)) {
      buffer += data;
      handleDelta(safeParse(buffer));
    }

    return null;
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderCloud;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
