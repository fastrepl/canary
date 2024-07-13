import { CanarySearch } from "./canary-search";
import { CanaryDialog } from "./canary-dialog";
import { CanaryPanel } from "./canary-panel";
import { CanaryInputAsk, CanaryInputSearch } from "./canary-input";

import { CanaryHeroIcon } from "./canary-hero-icon";
import { CanaryLogoCal } from "./canary-logo-cal";
import { CanaryLogoSlack } from "./canary-logo-slack";
import { CanaryLogoDiscord } from "./canary-logo-discord";

import { CanaryCalloutCal } from "./canary-callout-cal";
import { CanaryCalloutSlack } from "./canary-callout-slack";
import { CanaryCalloutDiscord } from "./canary-callout-discord";
declare global {
  interface HTMLElementTagNameMap {
    "canary-search": CanarySearch;
    "canary-dialog": CanaryDialog;
    "canary-panel": CanaryPanel;
    "canary-input-ask": CanaryInputAsk;
    "canary-input-search": CanaryInputSearch;
    "canary-hero-icon": CanaryHeroIcon;
    "canary-logo-cal": CanaryLogoCal;
    "canary-logo-slack": CanaryLogoSlack;
    "canary-logo-discord": CanaryLogoDiscord;
    "canary-callout-cal": CanaryCalloutCal;
    "canary-callout-slack": CanaryCalloutSlack;
    "canary-callout-discord": CanaryCalloutDiscord;
  }
}
