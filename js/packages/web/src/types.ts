import { CanarySearch } from "./canary-search";
import { CanaryDialog } from "./canary-dialog";
import { CanaryPanel } from "./canary-panel";
import { CanaryInputSearch } from "./canary-input-search";
import { CanaryInputAsk } from "./canary-input";
import { HeroIconMagnifyingGlass } from "./icons/magnifying-glass";
import { HeroIconQuestionMarkCircle } from "./icons/question-mark-circle";

declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
    "canary-dialog": CanaryDialog;
    "canary-panel": CanaryPanel;
    "canary-input-search": CanaryInputSearch;
    "canary-input-ask": CanaryInputAsk;
    "hero-magnifying-glass": HeroIconMagnifyingGlass;
    "hero-question-mark-circle": HeroIconQuestionMarkCircle;
  }
}
