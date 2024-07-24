import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type { Delta, Reference } from "./types";
import { wrapper } from "./styles";

const NAME = "canary-provider-pagefind";

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @state() pagefind: { search: (query: string) => Promise<any> } | null = null;

  @property() baseUrl = "";

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    if (!pagefind) {
      throw new Error("Pagefind is not available");
    }

    this.pagefind = pagefind;
    pagefind.init();

    this.dispatchEvent(
      new CustomEvent("register", {
        detail: { search: this.search, ask: this.ask },
        bubbles: true,
        composed: true,
      }),
    );
  }

  private _importPagefind() {
    if (!this.baseUrl) {
      throw new Error("baseUrl is required");
    }

    /* @vite-ignore */
    return import(new URL("/pagefind/pagefind.js", this.baseUrl).href);
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (query: string, _signal?: AbortSignal) => {
    const search = await this.pagefind!.search(query);

    const results: Reference[] = await Promise.all(
      search.results.slice(0, 10).map((result: any) =>
        result.data().then((d: any) => ({
          url: d.url,
          title: d.meta.title,
          excerpt: d.excerpt,
        })),
      ),
    );

    return results;
  };

  ask = async (
    _a: number,
    _b: string,
    _c: (delta: Delta) => void = () => {},
    _d?: AbortSignal,
  ) => {
    throw new Error("'ask' is not supported for this provider");
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
