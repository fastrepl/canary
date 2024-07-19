import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

// https://astro.build/config
export default defineConfig({
  redirects: { "/": "/intro/readme/" },
  site: "https://docs.getcanary.dev",
  integrations: [
    starlight({
      title: "🐤 Canary",
      social: {
        github: "https://github.com/fastrepl/canary",
      },
      editLink: {
        baseUrl: "https://github.com/fastrepl/canary/js/apps/docs",
      },
      sidebar: [
        {
          label: "Start Here",
          items: [
            { label: "README", link: "/intro/readme/" },
            { label: "Hosted vs Self-host", link: "/intro/hosting/" },
            { label: "Concepts", link: "/intro/concepts/" },
            { label: "Customization", link: "/intro/customization/" },
          ],
        },
        {
          label: "Integrations",
          items: [
            { label: "Starlight", link: "/integrations/starlight/" },
            { label: "Docusaurus", link: "/integrations/docusaurus/" },
          ],
        },
        {
          label: "Analytics",
          items: [{ label: "Tracker", link: "/analytics/tracker/" }],
        },
        {
          label: "Packages",
          collapsed: true,
          autogenerate: { directory: "packages" },
        },
      ],
      customCss: ["./src/styles/theme.css"],
      components: {
        Search: "./src/components/search.astro",
      },
      head: [
        ...[
          "canary-provider-pagefind",
          "canary-styles-starlight",
          "canary-modal",
          "canary-trigger-searchbar",
          "canary-content",
          "canary-search",
          "canary-search-input",
          "canary-search-results",
        ].map((c) => ({
          tag: "script",
          attrs: {
            type: "module",
            src: `https://unpkg.com/@getcanary/web@0.0.31/components/${c}.js`,
          },
        })),
      ],
    }),
  ],
});
