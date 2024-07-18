import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

import canary from "@getcanary/starlight";

// https://astro.build/config
export default defineConfig({
  redirects: { "/": "/intro/readme/" },
  site: "https://docs.getcanary.dev",
  integrations: [
    starlight({
      plugins: [canary()],
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
          ],
        },
        {
          label: "Integrations",
          items: [
            { label: "Overview", link: "/integrations/overview/" },
            { label: "Starlight", link: "/integrations/starlight/" },
            { label: "Docusaurus", link: "/integrations/docusaurus/" },
            { label: "Nextra", link: "/integrations/nextra/" },
            { label: "VitePress", link: "/integrations/vitepress/" },
          ],
        },
        {
          label: "Sources",
          items: [
            { label: "Overview", link: "/sources/overview/" },
            { label: "Website", link: "/sources/website/" },
          ],
        },
        {
          label: "Clients",
          items: [
            { label: "Overview", link: "/clients/overview/" },
            { label: "Discord", link: "/clients/discord/" },
            { label: "Website", link: "/clients/website/" },
          ],
        },
        {
          label: "Analytics",
          items: [
            { label: "Overview", link: "/analytics/overview/" },
            { label: "Tracker", link: "/analytics/tracker/" },
          ],
        },
        {
          label: "Packages",
          collapsed: true,
          autogenerate: { directory: "packages" },
        },
        {
          label: "Miscellaneous",
          collapsed: true,
          autogenerate: { directory: "others" },
        },
      ],
      customCss: ["./src/styles/theme.css"],
    }),
  ],
});
