import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import type {
  BeforeSearchFunction,
  SearchFunction,
  SearchResult,
  PagefindResult,
  PagefindSubResult,
} from "../types";

import { createEvent } from "../store";
import { stripURL } from "../utils";
import { wrapper } from "../styles";
import { cache } from "../decorators";

const NAME = "canary-provider-pagefind";

type Options = {
  path?: string;
  styles?: Record<string, string>;
  pagefind?: { ranking: Record<string, number> };
  _base?: string;
  _replace?: string;
  maxPages?: number;
  maxSubResults?: number;
};

const DEFAULT_MAX_PAGES = 20;
const DEFAULT_MAX_SUB_RESULTS = 3;

@customElement(NAME)
export class CanaryProviderPagefind extends LitElement {
  @property({ type: Object })
  options: Options = {};

  @state()
  private _pagefind: any | null = null;

  async connectedCallback() {
    super.connectedCallback();

    // @ts-expect-error
    let pagefind = window.pagefind;

    if (!pagefind) {
      try {
        pagefind = await import(
          /* @vite-ignore */
          /* webpackIgnore: true */
          this.options?.path ?? "/pagefind/pagefind.js"
        );
      } catch (e) {
        console.info(
          "Failed to import pagefind. Try serving app with production build.",
          e,
        );
        return;
      }
    }

    this._initPagefind(pagefind);

    this.dispatchEvent(
      createEvent({
        type: "register_operations",
        data: {
          search: cache(this.search),
          beforeSearch: this.beforeSearch,
        },
      }),
    );
  }

  private async _initPagefind(pagefind: any) {
    try {
      pagefind.init();
      if (this.options.pagefind) {
        await pagefind.options(this.options.pagefind);
      }
      this._pagefind = pagefind;
    } catch (e) {
      throw new Error(`Failed to initialize pagefind': ${e}`);
    }
  }

  render() {
    return html`<slot></slot>`;
  }

  static styles = wrapper;

  beforeSearch: BeforeSearchFunction = async (query) => {
    this._pagefind.preload(query);
  };

  search: SearchFunction = async ({ text: query, tags }, signal) => {
    const maxPages = this.options.maxPages ?? DEFAULT_MAX_PAGES;

    const { results: pages } = await this._pagefind.search(query);

    const matches: PagefindResult[] = await Promise.all(
      pages.slice(0, maxPages).map((r: any) => r.data()),
    ).then((results: PagefindResult[]) =>
      results.filter(({ meta }) => !meta.tag || tags.includes(meta.tag)),
    );

    signal.throwIfAborted();

    return { matches: this._transform(matches) };
  };

  private _transform(results: PagefindResult[]): SearchResult[] {
    const maxSubResults = this.options.maxSubResults ?? DEFAULT_MAX_SUB_RESULTS;

    const transformURL = (url: string) => {
      return this.options._base
        ? this.options._base +
            stripURL(url.replace(this.options._replace || "", ""))
        : url;
    };

    const getBestScore = (subResult: PagefindSubResult) =>
      subResult.weighted_locations.reduce(
        (acc, cur) => Math.max(acc, cur.balanced_score),
        -1,
      );

    return results
      .sort((a, b) => {
        return getBestScore(b.sub_results[0]) - getBestScore(a.sub_results[0]);
      })
      .map((result) => {
        const subs = result.sub_results
          .slice(0, maxSubResults)
          .map((subResult) => ({
            url: transformURL(subResult.url),
            title: subResult.title,
            excerpt: subResult.excerpt,
          }))
          .filter(({ title }, i) => !(i == 0 && title == result.meta.title));

        return {
          type: "webpage",
          meta: {},
          title: result.meta.title,
          url: transformURL(result.url),
          excerpt: result.excerpt,
          sub_results: subs,
        };
      });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderPagefind;
  }
  namespace JSX {
    interface IntrinsicElements {
      [NAME]: any;
    }
  }
}
