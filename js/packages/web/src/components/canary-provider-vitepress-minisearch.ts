import { LitElement, html } from "lit";
import { customElement, property, state } from "lit/decorators.js";

import { wrapper } from "../styles";
import type { SearchFunction, SearchReference } from "../types";
import { createEvent } from "../store";

const NAME = "canary-provider-vitepress-minisearch";

type SearchResult = {
  id: string;
  title: string;
  titles: string[];
};

@customElement(NAME)
export class CanaryProviderVitepressMinisearch extends LitElement {
  @property({ type: String }) localeIndex = "root";
  @property({ type: Object }) miniSearchOptions: any = {
    searchOptions: {},
    options: {},
  };

  @state()
  minisearch: {
    search: (query: string) => SearchResult[];
  } | null = null;

  async connectedCallback() {
    super.connectedCallback();
    const data = await this._importIndexData();
    const index = await this._buildIndex(data);

    this.minisearch = {
      search: (query) => index.search(query) as unknown as SearchResult[],
    };

    this.dispatchEvent(
      createEvent({
        type: "register_operations",
        data: { search: this.search },
      }),
    );
  }

  render() {
    return html`<slot></slot>`;
  }

  private async _importIndexData() {
    try {
      // @ts-expect-error
      const m = await import("@localSearchIndex");
      const data = (await m.default[this.localeIndex]?.())?.default;
      return data;
    } catch (e) {
      throw new Error(`Failed to import index from '@localSearchIndex': ${e}`);
    }
  }

  private async _buildIndex(data: any) {
    try {
      const { default: MiniSearch } = await import(
        /* @vite-ignore */
        // @ts-ignore
        "minisearch"
      );

      // https://github.com/vuejs/vitepress/blob/8f31a4c/src/client/theme-default/components/VPLocalSearchBox.vue#L72-L87
      const index = MiniSearch.loadJSON(data, {
        fields: ["title", "titles", "text"],
        storeFields: ["title", "titles"],
        searchOptions: {
          fuzzy: 0.2,
          prefix: true,
          boost: { title: 4, text: 2, titles: 1 },
          ...this.miniSearchOptions.searchOptions,
        },
        ...this.miniSearchOptions.options,
      });

      return index;
    } catch (e) {
      throw new Error(`Failed to import minisearch: ${e}`);
    }
  }

  static styles = wrapper;

  search: SearchFunction = async ({ query }, _signal) => {
    return new Promise((resolve) => {
      if (!this.minisearch) {
        resolve({ search: [] });
        return;
      }

      const refs: SearchReference[] = this.minisearch
        .search(query)
        .map((result) => ({
          url: new URL(result.id, window.location.origin).toString(),
          title: result.title,
          titles: result.titles,
        }));

      resolve({ search: refs });
    });
  };
}

declare global {
  interface HTMLElementTagNameMap {
    [NAME]: CanaryProviderVitepressMinisearch;
  }
}
