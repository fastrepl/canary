import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { AskFunction, Delta, SearchFunction } from "../types";

import { wrapper } from "../styles";
import { createEvent } from "../store";
import { cache } from "../decorators";

const NAME = "canary-provider-cloud";

@customElement(NAME)
export class CanaryProviderCloud extends LitElement {
  @property({ type: String, attribute: "api-base" })
  apiBase = "";

  @property({ type: String, attribute: "api-key" })
  apiKey = "";

  connectedCallback() {
    super.connectedCallback();

    if (!this.apiBase || !this.apiKey) {
      throw new Error("Endpoint and key are required");
    }

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
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ key: this.apiKey, query }),
      signal,
    };

    const res = await fetch(`${this.apiBase}/api/v1/search`, params);
    if (!res.ok) {
      throw new Error(res.statusText);
    }

    return res.json();
  };

  ask: AskFunction = async (id, query, handleDelta, signal) => {
    const url = `${this.apiBase}/api/v1/ask`;
    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, key: this.apiKey, query }),
      signal,
    };

    const res = await fetch(url, params);
    if (!res.ok) {
      throw new Error(res.statusText);
    }

    const reader = res.body?.pipeThrough(new TextDecoderStream()).getReader();

    if (!reader) {
      throw new Error();
    }

    while (true) {
      try {
        const { done, value } = await reader.read();
        if (done) {
          break;
        }

        value
          .split("\n\n")
          .flatMap((s) => s.split("data: "))
          .filter(Boolean)
          .map((s) => JSON.parse(s) as Delta)
          .forEach(handleDelta);
      } catch (error) {
        if (error instanceof Error && error.name !== "AbortError") {
          console.error(error);
        }

        break;
      }
    }

    return null;
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderCloud;
  }
}
