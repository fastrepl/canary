import type { ModeContext, OperationContext } from "./types";

type Event =
  | { name: "register-operations"; data: Partial<OperationContext> }
  | { name: "register-mode"; data: ModeContext["current"] }
  | { name: "mode-set"; data: ModeContext["current"] }
  | { name: "input-change"; data: string }
  | { name: "empty"; data: boolean }
  | { name: "modal-close"; data?: null };

export const customEvent = (event: Event, opts?: Record<string, any>) => {
  return new CustomEvent(event.name, {
    detail: event.data,
    composed: true,
    bubbles: true,
    ...opts,
  });
};

declare global {
  interface HTMLElementEventMap {}
}
