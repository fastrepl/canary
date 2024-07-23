import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { provide } from "@lit/context";
import { providerContext } from "./contexts";
import type { ProviderContext } from "./types";

import type { Delta } from "./types";
import { wrapper } from "./styles";

const NAME = "canary-provider-cloud";

@customElement(NAME)
export class CanaryProviderCloud extends LitElement {
  @provide({ context: providerContext })
  @state()
  root: ProviderContext = { type: "cloud" } as ProviderContext;

  @property() endpoint = "";
  @property() key = "";

  connectedCallback() {
    super.connectedCallback();

    if (!this.endpoint || !this.key) {
      throw new Error("Endpoint and key are required");
    }

    if (this.root.type !== "cloud") {
      throw new Error();
    }

    this.root.endpoint = this.endpoint;
    this.root.key = this.key;
    this.root.search = this.search;
    this.root.ask = this.ask;
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (query: string, signal?: AbortSignal) => {
    const url = `${this.endpoint}/api/v1/search`;

    const params = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ key: this.key, query }),
      signal,
    };

    const response = await fetch(url, params);
    if (!response.ok) {
      throw new Error();
    }

    return response.json();
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

    const response = await fetch(url, params);
    if (!response.ok) {
      throw new Error();
    }

    const reader = response.body
      ?.pipeThrough(new TextDecoderStream())
      .getReader();

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
