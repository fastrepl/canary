import { CanaryProviderMock } from "./canary-provider-mock";
import { CanaryProviderCloud } from "./canary-provider-cloud";
import { CanaryProviderPagefind } from "./canary-provider-pagefind";

import { CanaryModal } from "./canary-modal";
import { CanaryDialog } from "./canary-dialog";
import { CanaryContent } from "./canary-content";

import { CanaryInputAsk } from "./canary-input-ask";
import { CanaryInputSearch } from "./canary-input-search";

import { CanaryResultSearch } from "./canary-result-search";
import { CanaryResultAsk } from "./canary-result-ask";

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

import { CanaryModeTabs } from "./canary-mode-tabs";
import { CanarySearchTabs } from "./canary-search-tabs";

import { CanaryFooter } from "./canary-footer";
import { CanaryMarkdown } from "./canary-markdown";

import { CanaryStylesDefault } from "./canary-styles-default";
import { CanaryStylesStarlight } from "./canary-styles-starlight";
import { CanaryStylesDocusaurus } from "./canary-styles-docusaurus";

declare global {
  interface HTMLElementTagNameMap {
    "canary-provider-mock": CanaryProviderMock;
    "canary-provider-cloud": CanaryProviderCloud;
    "canary-provider-pagefind": CanaryProviderPagefind;
    "canary-modal": CanaryModal;
    "canary-dialog": CanaryDialog;
    "canary-content": CanaryContent;
    "canary-input-ask": CanaryInputAsk;
    "canary-input-search": CanaryInputSearch;
    "canary-result-search": CanaryResultSearch;
    "canary-result-ask": CanaryResultAsk;
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
    "canary-markdown": CanaryMarkdown;
    "canary-mode-tabs": CanaryModeTabs;
    "canary-search-tabs": CanarySearchTabs;
    "canary-styles-default": CanaryStylesDefault;
    "canary-styles-starlight": CanaryStylesStarlight;
    "canary-styles-docusaurus": CanaryStylesDocusaurus;
  }
}

export type Delta =
  | DeltaError
  | DeltaProgress
  | DeltaComplete
  | DeltaReferences;

type DeltaError = {
  type: "error";
  reason: string;
};

type DeltaProgress = {
  type: "progress";
  content: string;
};

type DeltaComplete = {
  type: "complete";
};

type DeltaReferences = {
  type: "references";
  items: Reference[];
};

export type Reference = {
  title: string;
  url: string;
  excerpt?: string;
};
