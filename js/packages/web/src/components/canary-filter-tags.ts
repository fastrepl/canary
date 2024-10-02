import { LitElement, css, html, PropertyValues } from "lit";
import { customElement, property } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";

import { StringArray } from "../converters";
import { createEvent } from "../store";

const NAME = "canary-filter-tags";

@customElement(NAME)
export class CanaryFilterTags extends LitElement {
  @property({ converter: StringArray })
  tags: string[] = [];

  @property({ type: String, attribute: "local-storage-key" })
  localStorageKey?: string;

  @property({ type: String })
  selected = "";

  connectedCallback() {
    super.connectedCallback();
    this._initializeSelected();
  }

  updated(changed: PropertyValues<this>) {
    if (changed.has("selected") && this.localStorageKey) {
      localStorage.setItem(this.localStorageKey, this.selected);
    }
  }

  private _initializeSelected() {
    if (this.selected) {
      return;
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
            @click=${() => this._handleClick(tag)}
            part=${["tag", selected ? "active" : "inactive"].join(" ")}
            class=${classMap({ tag: true, active: selected })}
          >
            ${tag}
          </button>`;
        })}
      </div>
    `;
  }

  private _handleClick(tag: string) {
    if (this.selected === tag) {
      return;
    }

    this.selected = tag;
    this.dispatchEvent(
      createEvent({ type: "set_query", data: { tags: [tag], text: "" } }),
    );
  }

  static styles = css`
    .container {
      display: flex;
      flex-direction: row;
      align-items: center;
      gap: 8px;
    }

    .tag {
      cursor: pointer;
      font-size: 1em;
      padding: 1px 8px;
      min-width: 40px;
      border-radius: 4px;
      border: 1px solid var(--canary-color-gray-50);
      color: var(--canary-color-gray-20);
      background-color: var(--canary-is-light, var(--canary-color-gray-95))
        var(--canary-is-dark, var(--canary-color-gray-80));
    }

    .tag:hover,
    .tag.active {
      color: var(--canary-is-light, var(--canary-color-primary-40))
        var(--canary-is-dark, var(--canary-color-primary-20));
      border-color: var(--canary-is-light, var(--canary-color-primary-50))
        var(--canary-is-dark, var(--canary-color-primary-50));
      background-color: var(--canary-is-light, var(--canary-color-primary-95))
        var(--canary-is-dark, var(--canary-color-primary-70));
    }
  `;
}
