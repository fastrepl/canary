import { defineConfig } from "unocss";
import presetUno from "@unocss/preset-uno";
import presetIcons from "@unocss/preset-icons";

const heroiconsLoader = () =>
  import("@iconify-json/heroicons/icons.json").then((i) => i.default);
const phLoader = () =>
  import("@iconify-json/ph/icons.json").then((i) => i.default) as ReturnType<
    typeof heroiconsLoader
  >;

export default defineConfig({
  presets: [
    presetUno(),
    presetIcons({
      extraProperties: {
        color: "var(--canary-color-gray-20)",
      },
      collections: {
        ph: phLoader,
        heroicons: heroiconsLoader,
      },
    }),
  ],
});
