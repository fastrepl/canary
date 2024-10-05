import { LitElement, css, html, PropertyValues } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import pm from "picomatch";

import { StringArray } from "../converters";
import { createEvent } from "../store";
import { TagUrlSyncDefinition } from "../types";

const NAME = "canary-filter-tags";

@customElement(NAME)
export class CanaryFilterTags extends LitElement {
  @property({ converter: StringArray })
  tags: string[] = [];

  @property({ type: Object, attribute: "url-sync" })
  syncURL?: TagUrlSyncDefinition;

  @property({ type: String, attribute: "local-storage-key" })
  localStorageKey?: string;

  @property({ type: String })
  selected = "";

  connectedCallback() {
    super.connectedCallback();
    this._ensureTagsConverted();
    this._initializeSelected();
  }

  updated(changed: PropertyValues<this>) {
    if (changed.has("selected") && this.localStorageKey) {
      localStorage.setItem(this.localStorageKey, this.selected);
    }

    if (changed.has("selected")) {
      this.dispatchEvent(
        createEvent({ type: "set_query", data: { tags: [this.selected] } }),
      );
    }
  }

  private _ensureTagsConverted() {
    if (typeof this.tags === "string") {
      this.tags = StringArray.fromAttribute(this.tags, null);
    }
  }

  private _initializeSelected() {
    if (this.selected) {
      return;
    }

    if (this.syncURL) {
      const { hostname, pathname } = new URL(window.location.href);
      const found = this.syncURL.find(({ pattern }) =>
        pm(pattern)(`${hostname}${pathname}`),
      );

      if (found) {
        this.selected = found.tag;
        return;
      }
    }

    if (!this.localStorageKey) {
      this.selected = this.tags[0];
      return;
    }

    const storedValue = localStorage.getItem(this.localStorageKey);
    if (storedValue && this.tags.includes(storedValue)) {
      this.selected = storedValue;
    } else {
      this.selected = this.tags[0];
    }
  }

  render() {
    return html`
      <div class="container" part="container">
        ${this.tags.map((tag) => {
          const selected = tag === this.selected;

          return html`<button
            @click=${() => (this.selected = tag)}
            part=${["tag", selected ? "active" : "inactive"].join(" ")}
            class=${classMap({ tag: true, active: selected })}
          >
            ${tag}
          </button>`;
        })}
      </div>
    `;
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: flex-start;
      gap: 8px;
      padding-top: 4px;
      padding-bottom: 4px;
    }

    .tag {
      cursor: pointer;
      font-size: 0.9em;
      padding: 1px 8px;
      min-width: 40px;

      border: 1px solid;
      border-radius: 8px;
      border-color: var(--canary-is-light, var(--canary-color-gray-80))
        var(--canary-is-dark, var(--canary-color-gray-50));

      color: var(--canary-is-light, var(--canary-color-gray-60))
        var(--canary-is-dark, var(--canary-color-gray-40));
      background-color: var(--canary-is-light, var(--canary-color-gray-95))
        var(--canary-is-dark, var(--canary-color-gray-80));
    }

    .tag:hover,
    .tag.active {
      color: var(--canary-is-light, var(--canary-color-primary-40))
        var(--canary-is-dark, var(--canary-color-primary-20));
      border-color: var(--canary-is-light, var(--canary-color-primary-80))
        var(--canary-is-dark, var(--canary-color-primary-50));
      background-color: var(--canary-is-light, var(--canary-color-primary-95))
        var(--canary-is-dark, var(--canary-color-primary-70));
    }
  `;
}
