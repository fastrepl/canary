import { LitElement, html, type PropertyValues } from "lit";
import { property } from "lit/decorators.js";

import { registerCustomElement } from "../decorators";
import { parse as safeParse } from "best-effort-json-parser";

import type { AskFunction, SearchFunction } from "../types";

import { wrapper } from "../styles";
import { createEvent } from "../store";
import { cache } from "../decorators/cache";
import { StringArray } from "../converters";
import { sseIterator } from "../utils";

const NAME = "canary-provider-cloud";

@registerCustomElement(NAME)
export class CanaryProviderCloud extends LitElement {
  @property({ type: String, attribute: "api-base" })
  apiBase = "";

  @property({ type: String, attribute: "api-key" })
  apiKey = "";

  @property({ converter: StringArray, attribute: "sources" })
  sources: string[] = [];

  connectedCallback() {
    super.connectedCallback();

    if (!this.apiBase || !this.apiKey) {
      throw new Error("Endpoint and key are required");
    }

    this._dispatchOperations();
    this._dispatchSources();
  }

  updated(changed: PropertyValues<this>) {
    if (changed.get("sources")) {
      this._dispatchSources();
    }
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

  private _dispatchSources() {
    this.dispatchEvent(
      createEvent({
        type: "set_query",
        data: { sources: this.sources.filter(Boolean) },
      }),
    );
  }

  search: SearchFunction = async (query, signal) => {
    const params = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({ query }),
      signal,
    };

    const res = await fetch(`${this.apiBase}/api/v1/search`, params);
    if (!res.ok) {
      throw new Error(res.statusText);
    }

    return res.json();
  };

  ask: AskFunction = async (query, handleDelta, signal) => {
    const url = `${this.apiBase}/api/v1/ask`;
    const req = new Request(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${this.apiKey}`,
      },
      body: JSON.stringify({ query }),
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
