import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";

import starlightOpenAPI, { openAPISidebarGroups } from "starlight-openapi";

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
          label: "Packages",
          collapsed: true,
          autogenerate: { directory: "packages" },
        },
        {
          label: "Miscellaneous",
          collapsed: true,
          autogenerate: { directory: "others" },
        },
        ...openAPISidebarGroups,
      ],
      customCss: ["./src/styles/theme.css"],
      plugins: [
        starlightOpenAPI([
          {
            base: "api",
            label: "API Reference",
            schema: "https://cloud.getcanary.dev/api/openapi",
            collapsed: true,
          },
        ]),
      ],
    }),
  ],
});
