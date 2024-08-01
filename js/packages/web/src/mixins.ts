import { LitElement } from "lit";
import { property, state } from "lit/decorators.js";

import { consume } from "@lit/context";
import { queryContext } from "./contexts";

type Constructor<T = {}> = new (...args: any[]) => T;

export declare class CalloutMixinInterface {
  protected show(): boolean;
}

export const CalloutMixin = <T extends Constructor<LitElement>>(
  superClass: T,
) => {
  class Mixin extends superClass {
    @property({ type: Array }) keywords: string[] = [];
    @property({ type: Boolean }) forceShow = false;

    @consume({ context: queryContext, subscribe: true })
    @state()
    private _query = "";

    protected show() {
      if (this.forceShow) {
        return true;
      }

      return this.keywords.some((keyword) =>
        (this._query ?? "").includes(keyword),
      );
    }
  }

  return Mixin as unknown as Constructor<CalloutMixinInterface> & T;
};
