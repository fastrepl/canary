import { CanaryModal } from "./canary-modal";
import { CanaryDialog } from "./canary-dialog";
import { CanaryPanel } from "./canary-panel";
import { CanaryInputAsk, CanaryInputSearch } from "./canary-input";

import { CanaryHeroIcon } from "./canary-hero-icon";
import { CanaryLogoCal } from "./canary-logo-cal";
import { CanaryLogoCalendly } from "./canary-logo-calendly";
import { CanaryLogoSlack } from "./canary-logo-slack";
import { CanaryLogoDiscord } from "./canary-logo-discord";

import { CanaryCalloutCal } from "./canary-callout-cal";
import { CanaryCalloutCalendly } from "./canary-callout-calendly";
import { CanaryCalloutSlack } from "./canary-callout-slack";
import { CanaryCalloutDiscord } from "./canary-callout-discord";

import { CanaryReference } from "./canary-reference";
import { CanaryReferenceSkeleton } from "./canary-reference-skeleton";

import { CanaryFooter } from "./canary-footer";

declare global {
  interface HTMLElementTagNameMap {
    "canary-modal": CanaryModal;
    "canary-dialog": CanaryDialog;
    "canary-panel": CanaryPanel;
    "canary-input-ask": CanaryInputAsk;
    "canary-input-search": CanaryInputSearch;
    "canary-hero-icon": CanaryHeroIcon;
    "canary-logo-cal": CanaryLogoCal;
    "canary-logo-calendly": CanaryLogoCalendly;
    "canary-logo-slack": CanaryLogoSlack;
    "canary-logo-discord": CanaryLogoDiscord;
    "canary-callout-cal": CanaryCalloutCal;
    "canary-callout-calendly": CanaryCalloutCalendly;
    "canary-callout-slack": CanaryCalloutSlack;
    "canary-callout-discord": CanaryCalloutDiscord;
    "canary-reference": CanaryReference;
    "canary-reference-skeleton": CanaryReferenceSkeleton;
    "canary-footer": CanaryFooter;
  }
}
