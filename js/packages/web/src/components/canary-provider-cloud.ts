import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";
import { parse as safeParse } from "best-effort-json-parser";

import type { AskFunction, SearchFunction } from "../types";

import { wrapper } from "../styles";
import { createEvent } from "../store";
import { cache } from "../decorators";
import { StringArray } from "../converters";
import { sseIterator } from "../utils";

const NAME = "canary-provider-cloud";

@customElement(NAME)
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

    this.dispatchEvent(
      createEvent({
        type: "set_query",
        data: { sources: this.sources.filter(Boolean) },
      }),
    );

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

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

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
