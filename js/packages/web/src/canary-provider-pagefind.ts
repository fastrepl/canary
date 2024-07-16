import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { provide } from "@lit/context";
import { providerContext, type ProviderContext } from "./contexts";

import { Delta } from "./types";

@customElement("canary-provider-pagefind")
export class CanaryProviderPagefind extends LitElement {
  @provide({ context: providerContext })
  @state()
  root: ProviderContext = { type: "pagefind" } as ProviderContext;

  @property() baseUrl = "";
  @property() bundlePath = "";

  @state() pagefind: { search: (query: string) => Promise<any> } | null = null;

  async connectedCallback() {
    super.connectedCallback();

    // @ts-ignore
    const pagefind = await import("/pagefind/pagefind.js");
    if (!pagefind) {
      throw new Error("Pagefind is not available");
    }

    await pagefind.options({
      baseUrl: this.baseUrl,
      bundlePath: this.bundlePath,
    });

    pagefind.init();

    if (this.root.type !== "pagefind") {
      throw new Error();
    }

    this.root.search = this.search;
    this.root.ask = this.ask;
  }

  render() {
    return html`<slot></slot>`;
  }

  search = async (query: string, _signal?: AbortSignal) => {
    const search = await this.pagefind!.search(query);
    const results = await Promise.all(
      search.results.slice(0, 10).map((r: any) => r.data()),
    );

    console.log(results);
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
