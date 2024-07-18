import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { provide } from "@lit/context";
import { providerContext, type ProviderContext } from "./contexts";

import type { Delta, Reference } from "./types";

@customElement("canary-provider-pagefind")
export class CanaryProviderPagefind extends LitElement {
  @provide({ context: providerContext })
  @state()
  root: ProviderContext = { type: "pagefind" } as ProviderContext;

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

    if (this.root.type !== "pagefind") {
      throw new Error();
    }

    this.root.search = this.search;
    this.root.ask = this.ask;
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
