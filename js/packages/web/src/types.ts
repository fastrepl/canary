import { CanarySearch } from "./canary-search";
import { CanaryDialog } from "./canary-dialog";
import { CanaryPanel } from "./canary-panel";
import { CanaryInputAsk, CanaryInputSearch } from "./canary-input";
import { CanaryHeroIcon } from "./canary-hero-icon";

declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
    "canary-dialog": CanaryDialog;
    "canary-panel": CanaryPanel;
    "canary-input-ask": CanaryInputAsk;
    "canary-input-search": CanaryInputSearch;
    "canary-hero-icon": CanaryHeroIcon;
  }
}
