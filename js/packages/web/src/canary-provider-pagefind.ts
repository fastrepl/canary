import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type { Reference } from "./types";
import { wrapper } from "./styles";

const NAME = "canary-provider-pagefind";

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @state() pagefind: { search: (query: string) => Promise<any> } | null = null;

  @property({ type: String }) baseUrl = "";
  @property({ type: String }) bundlePath = "/pagefind/pagefind.js";

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    if (!pagefind) {
      throw new Error("Pagefind is not available");
    }

    pagefind.init();
    this.pagefind = pagefind;

    this.dispatchEvent(
      new CustomEvent("register", {
        detail: { search: this.search },
        bubbles: true,
        composed: true,
      }),
    );
  }

  private async _importPagefind() {
    try {
      const path = this.baseUrl
        ? new URL(this.bundlePath, this.baseUrl).href
        : this.bundlePath;

      return import(path);
    } catch (e) {
      throw new Error(`Failed to import index from '@localSearchIndex': ${e}`);
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (query: string, _?: AbortSignal): Promise<Reference[]> => {
    const { results } = await this.pagefind!.search(query);

    return Promise.all(
      results.map((result: any) =>
        result.data().then((d: any) => ({
          url: d.url,
          title: d.meta.title,
          excerpt: d.excerpt,
        })),
      ),
    );
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
