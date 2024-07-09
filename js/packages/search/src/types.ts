import { CanarySearch } from "./canary-search";
import { CanaryDialog } from "./canary-dialog";
import { CanaryPanel } from "./canary-panel";
import { HeroIconMagnifyingGlass } from "./icons/magnifying-glass";
import { HeroIconQuestionMarkCircle } from "./icons/question-mark-circle";

declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
    "canary-dialog": CanaryDialog;
    "canary-panel": CanaryPanel;
    "hero-magnifying-glass": HeroIconMagnifyingGlass;
    "hero-question-mark-circle": HeroIconQuestionMarkCircle;
  }
}

export type SearchResultItem = {
  url: string;
  excerpt: string;
  meta: SearchResultMeta;
};

type SearchResultMeta = {
  title: string;
};
