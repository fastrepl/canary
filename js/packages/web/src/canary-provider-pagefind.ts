import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type { SearchReference } from "./types";
import type { PagefindResult, PagefindSubResult } from "./types/pagefind";
import { wrapper } from "./styles";

const NAME = "canary-provider-pagefind";

type Options = {
  path?: string;
  styles?: Record<string, string>;
  pagefind?: { ranking: Record<string, number> };
};

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @property({ type: Object }) options: Options = {};
  @state() pagefind: any = null;

  async connectedCallback() {
    super.connectedCallback();

    const pagefind = await this._importPagefind();
    this._initPagefind(pagefind);
    this._applyStyles();

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
        this.options?.path ?? "/pagefind/pagefind.js"
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

  private _applyStyles() {
    if (this.options.styles) {
      Object.entries(this.options.styles).forEach(([key, value]) => {
        document.body.style.setProperty(key, value);
      });
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  search = async (
    query: string,
    _?: AbortSignal,
  ): Promise<SearchReference[] | null> => {
    const search = await this.pagefind.debouncedSearch(
      query,
      this.options.pagefind ?? {},
      200,
    );
    if (!search) {
      return new Promise((resolve) => resolve(null));
    }

    const results: (PagefindSubResult & { meta: PagefindResult["meta"] })[] =
      await Promise.all(
        search.results.map((result: any) =>
          result.data().then((result: PagefindResult) => {
            return result.sub_results.map((subResult) => ({
              ...subResult,
              meta: result.meta,
            }));
          }),
        ),
      ).then((results) => results.flat());

    const getBestScore = (subResult: PagefindSubResult) =>
      subResult.weighted_locations.reduce(
        (acc, cur) => Math.max(acc, cur.balanced_score),
        -1,
      );

    return results
      .sort((a, b) => getBestScore(b) - getBestScore(a))
      .map(
        (result) =>
          ({
            url: result.url,
            title: `${result.title} | ${result.meta.title}`,
            excerpt: result.excerpt,
          }) as SearchReference,
      );
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
}
