import { type Preview } from "@storybook/web-components";
import { withThemeByDataAttribute } from "@storybook/addon-themes";
import { MINIMAL_VIEWPORTS } from "@storybook/addon-viewport";

import { html } from "lit";
import "../src/components/canary-root";
import "../src/components/canary-provider-cloud";

import { initialize, mswLoader } from "msw-storybook-addon";
initialize();

import { searchHandler, askHandler, feedbackPageHandler } from "../src/msw";
import "../src/stories.css";

const preview: Preview = {
  tags: ["!autodocs"],
  loaders: [mswLoader],
  decorators: [
    (story) =>
      html` <canary-root framework="starlight">
        <canary-provider-cloud api-base="/" api-key="key">
          ${story()}
        </canary-provider-cloud>
      </canary-root>`,
    withThemeByDataAttribute({
      themes: { light: "light", dark: "dark" },
      parentSelector: "html",
      defaultTheme: "light",
      attributeName: "data-theme",
    }),
  ],
  parameters: {
    options: {
      storySort: {
        order: ["public-components", "examples", "private-components"],
      },
    },
    sourceLinkPrefix:
      "https://github.com/fastrepl/canary/tree/main/js/packages/web/src/",
    viewport: {
      viewports: { ...MINIMAL_VIEWPORTS },
      disable: true,
    },
    cssprops: {
      "canary-color-primary-c": { value: "0.1" },
      "canary-color-primary-h": { value: "260" },
    },
    msw: {
      handlers: {
        search: searchHandler,
        ask: askHandler,
        feedbackPage: feedbackPageHandler,
      },
    },
  },
};

export default preview;
