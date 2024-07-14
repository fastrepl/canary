import { type Preview } from "@storybook/web-components";
import { withThemeByClassName } from "@storybook/addon-themes";
import { MINIMAL_VIEWPORTS } from "@storybook/addon-viewport";

import "../src/stories.css";

const preview: Preview = {
  decorators: [
    withThemeByClassName({
      defaultTheme: "starlight-ocean-light",
      themes: {
        "starlight-ocean-light": "starlight-ocean-light bg-gray-100",
        "starlight-ocean-dark": "starlight-ocean-dark bg-gray-900",
        "starlight-oxide-light": "starlight-oxide-light bg-gray-100",
        "starlight-oxide-dark": "starlight-oxide-dark bg-gray-900",
      },
    }),
    // withThemeByDataAttribute({
    //   themes: { light: "light", dark: "dark" },
    //   parentSelector: "html",
    //   defaultTheme: "dark",
    //   attributeName: "data-theme",
    // }),
  ],
  parameters: {
    sourceLinkPrefix:
      "https://github.com/fastrepl/canary/tree/main/js/packages/web/src/",
    viewport: {
      viewports: {
        ...MINIMAL_VIEWPORTS,
      },
    },
  },
};

export default preview;
