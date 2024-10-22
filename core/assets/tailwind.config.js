// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/canary_web.ex",
    "../lib/canary_web/**/*.*ex",
    "./svelte/**/*.svelte",
    '../deps/live_toast/lib/**/*.*ex',
  ],
  theme: {
    extend: {
      colors: {
        "c-primary-0": "var(--canary-color-primary-0)",
        "c-primary-5": "var(--canary-color-primary-5)",
        "c-primary-10": "var(--canary-color-primary-10)",
        "c-primary-20": "var(--canary-color-primary-20)",
        "c-primary-30": "var(--canary-color-primary-30)",
        "c-primary-40": "var(--canary-color-primary-40)",
        "c-primary-50": "var(--canary-color-primary-50)",
        "c-primary-60": "var(--canary-color-primary-60)",
        "c-primary-70": "var(--canary-color-primary-70)",
        "c-primary-80": "var(--canary-color-primary-80)",
        "c-primary-90": "var(--canary-color-primary-90)",
        "c-primary-95": "var(--canary-color-primary-95)",
        "c-primary-100": "var(--canary-color-primary-100)",
        "c-gray-0": "var(--canary-color-gray-0)",
        "c-gray-5": "var(--canary-color-gray-5)",
        "c-gray-10": "var(--canary-color-gray-10)",
        "c-gray-20": "var(--canary-color-gray-20)",
        "c-gray-30": "var(--canary-color-gray-30)",
        "c-gray-40": "var(--canary-color-gray-40)",
        "c-gray-50": "var(--canary-color-gray-50)",
        "c-gray-60": "var(--canary-color-gray-60)",
        "c-gray-70": "var(--canary-color-gray-70)",
        "c-gray-80": "var(--canary-color-gray-80)",
        "c-gray-90": "var(--canary-color-gray-90)",
        "c-gray-95": "var(--canary-color-gray-95)",
        "c-gray-100": "var(--canary-color-gray-100)",
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [
        ".phx-no-feedback&",
        ".phx-no-feedback &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]),
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            let size = theme("spacing.6");
            if (name.endsWith("-mini")) {
              size = theme("spacing.5");
            } else if (name.endsWith("-micro")) {
              size = theme("spacing.4");
            }
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: size,
              height: size,
            };
          },
        },
        { values },
      );
    }),
  ],
};
