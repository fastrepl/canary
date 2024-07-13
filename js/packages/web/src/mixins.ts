import { LitElement, nothing } from "lit";
import { property } from "lit/decorators.js";
import { MutationController } from "@lit-labs/observers/mutation-controller.js";

type Constructor<T = {}> = new (...args: any[]) => T;

const ELEMENT_NAME = "canary-panel";
const ATTRIBUTE_NAME = "query";

export function CalloutMixin<T extends Constructor<LitElement>>(superClass: T) {
  class Mixin extends superClass {
    @property() url = "";
    @property({ type: Array }) keywords: string[] = [];

    private _observer = new MutationController<string>(this, {
      target: this.closest(ELEMENT_NAME),
      config: { attributeFilter: [ATTRIBUTE_NAME] },
      callback: (mutations) => {
        if (mutations.length === 0) {
          const target = this.closest(ELEMENT_NAME);
          const initial = target?.getAttribute(ATTRIBUTE_NAME) ?? "";
          this.requestUpdate();
          return initial;
        }

        const m = mutations.find((m) => m.attributeName === ATTRIBUTE_NAME);
        if (!m?.target) {
          return "";
        }

        return (m.target as HTMLElement).getAttribute(ATTRIBUTE_NAME) ?? "";
      },
    });

    render() {
      return this.show() ? this.renderCallout() : nothing;
    }

    private show() {
      const query = this._observer.value;
      return this.keywords.some((keyword) => (query ?? "").includes(keyword));
    }

    protected renderCallout(): unknown {
      throw new Error("renderCallout must be implemented");
    }
  }

  return Mixin;
}
