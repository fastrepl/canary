import { LitElement, html } from "lit";
import { customElement, property } from "lit/decorators.js";

import type { Delta } from "../types";
import { wrapper } from "../styles";
import { createEvent } from "../store";
import { cache } from "../decorators";

const NAME = "canary-provider-cloud";

@customElement(NAME)
export class CanaryProviderCloud extends LitElement {
  @property() endpoint = "";
  @property() key = "";

  connectedCallback() {
    super.connectedCallback();

    if (!this.endpoint || !this.key) {
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

  search = async (query: string, signal?: AbortSignal) => {
    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ key: this.key, query }),
      signal,
    };

    const res = await fetch(`${this.endpoint}/api/v1/search`, params);
    if (!res.ok) {
      throw new Error(res.statusText);
    }

    return res.json();
  };

  ask = async (
    id: number,
    query: string,
    handleDelta: (delta: Delta) => void = () => {},
    signal?: AbortSignal,
  ) => {
    const url = `${this.endpoint}/api/v1/ask`;
    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ id, key: this.key, query }),
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
