import { type Preview } from "@storybook/web-components";
import { withThemeByDataAttribute } from "@storybook/addon-themes";
import { MINIMAL_VIEWPORTS } from "@storybook/addon-viewport";

import { html } from "lit";
import "../src/components/canary-root";

import { initialize, mswLoader } from "msw-storybook-addon";
initialize();

import { searchHandler, askHandler } from "../src/msw";
import "../src/stories.css";

const preview: Preview = {
  loaders: [mswLoader],
  decorators: [
    (story) =>
      html`<canary-root framework="starlight">${story()}</canary-root>`,
    withThemeByDataAttribute({
      themes: { light: "light", dark: "dark" },
      parentSelector: "html",
      defaultTheme: "light",
      attributeName: "data-theme",
    }),
  ],
  parameters: {
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
      },
    },
  },
};

export default preview;
