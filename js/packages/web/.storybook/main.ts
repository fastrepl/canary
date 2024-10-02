import { join, dirname } from "path";
import type { StorybookConfig } from "@storybook/web-components-vite";

function getAbsolutePath(value: string): any {
  return dirname(require.resolve(join(value, "package.json")));
}
const config: StorybookConfig = {
  stories: ["../src/**/*.stories.ts", "../src/**/*.mdx"],
  staticDirs: ["../public"],
  addons: [
    getAbsolutePath("@storybook/addon-docs"),
    getAbsolutePath("storybook-source-link"),
    getAbsolutePath("@storybook/addon-themes"),
    getAbsolutePath("@storybook/addon-a11y"),
    getAbsolutePath("@storybook/addon-viewport"),
    getAbsolutePath("@storybook/addon-actions"),
    getAbsolutePath("@storybook/addon-interactions"),
    getAbsolutePath("@ljcl/storybook-addon-cssprops"),
  ],
  framework: {
    name: getAbsolutePath("@storybook/web-components-vite"),
    options: {},
  },
};
export default config;
