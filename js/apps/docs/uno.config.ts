import { defineConfig } from "unocss";
import presetWind from "@unocss/preset-wind";
import presetIcons from "@unocss/preset-icons";

export default defineConfig({
  presets: [
    presetWind({ important: true }),
    presetIcons({
      collections: {
        heroicons: () =>
          import("@iconify-json/heroicons/icons.json").then((i) => i.default),
      },
    }),
  ],
  theme: {
    colors: {
      primary: {
        0: "var(--canary-color-primary-0)",
        5: "var(--canary-color-primary-5)",
        10: "var(--canary-color-primary-10)",
        20: "var(--canary-color-primary-20)",
        30: "var(--canary-color-primary-30)",
        40: "var(--canary-color-primary-40)",
        50: "var(--canary-color-primary-50)",
        60: "var(--canary-color-primary-60)",
        70: "var(--canary-color-primary-70)",
        80: "var(--canary-color-primary-80)",
        90: "var(--canary-color-primary-90)",
        95: "var(--canary-color-primary-95)",
        100: "var(--canary-color-primary-100)",
      },
      gray: {
        0: "var(--canary-color-gray-0)",
        5: "var(--canary-color-gray-5)",
        10: "var(--canary-color-gray-10)",
        20: "var(--canary-color-gray-20)",
        30: "var(--canary-color-gray-30)",
        40: "var(--canary-color-gray-40)",
        50: "var(--canary-color-gray-50)",
        60: "var(--canary-color-gray-60)",
        70: "var(--canary-color-gray-70)",
        80: "var(--canary-color-gray-80)",
        90: "var(--canary-color-gray-90)",
        95: "var(--canary-color-gray-95)",
        100: "var(--canary-color-gray-100)",
      },
    },
  },
});
