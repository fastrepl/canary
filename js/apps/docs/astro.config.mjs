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
            { label: "Self-host", link: "/intro/self-host/" },
            { label: "Cloud", link: "/intro/cloud/" },
          ],
        },
        {
          label: "Sources",
          items: [
            { label: "Overview", link: "/sources/overview/" },
            { label: "Website", link: "/sources/website/" },
            { label: "Github", link: "/sources/github/" },
          ],
        },
        {
          label: "Clients",
          items: [
            { label: "Overview", link: "/clients/overview/" },
            { label: "Website", link: "/clients/website/" },
            { label: "Discord", link: "/clients/discord/" },
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
