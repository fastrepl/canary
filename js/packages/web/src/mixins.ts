import { LitElement, nothing } from "lit";
import { property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext } from "./contexts";

type Constructor<T = {}> = new (...args: any[]) => T;

export function CalloutMixin<T extends Constructor<LitElement>>(superClass: T) {
  class Mixin extends superClass {
    @property({ type: Array }) keywords: string[] = [];
    @property({ type: Boolean }) forceShow = false;

    @consume({ context: queryContext, subscribe: true })
    @state()
    query = "";

    render() {
      return this.show() ? this.renderCallout() : nothing;
    }

    private show() {
      if (this.forceShow) {
        return true;
      }

      return this.keywords.some((keyword) =>
        (this.query ?? "").includes(keyword),
      );
    }

    protected renderCallout(): unknown {
      throw new Error("renderCallout must be implemented");
    }
  }

  return Mixin as T;
}
