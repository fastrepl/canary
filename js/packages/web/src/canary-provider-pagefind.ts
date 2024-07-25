import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type { Reference } from "./types";
import type { PagefindResult } from "./types/pagefind";
import { wrapper } from "./styles";

const NAME = "canary-provider-pagefind";

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @state() pagefind: { search: (query: string) => Promise<any> } | null = null;

  @property({ type: String }) path = "/pagefind/pagefind.js";

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    this._initPagefind(pagefind);

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
      return import(
        /* @vite-ignore */
        /* webpackIgnore: true */
        this.path
      );
    } catch (e) {
      throw new Error(`Failed to import pagefind': ${e}`);
    }
  }

  private async _initPagefind(pagefind: any) {
    try {
      pagefind.init();
      this.pagefind = pagefind;
    } catch (e) {
      throw new Error(`Failed to initialize pagefind': ${e}`);
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
        result.data().then((data: PagefindResult) => {
          return data.sub_results.map((subResult) => ({
            url: subResult.url,
            title: `${subResult.title} | ${data.meta.title}`,
            excerpt: subResult.excerpt,
          }));
        }),
      ),
    ).then((arr) => arr.flat());
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
