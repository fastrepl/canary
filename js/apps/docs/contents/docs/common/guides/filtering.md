<script setup lang="ts">
import { onMounted, ref, computed } from "vue";
import { useData } from "vitepress";

import { data } from "@data/url_cloud.data";

const loaded = ref(false);

const tabs = ref([
  { name: "Docs", pattern: "getcanary.dev/**" },
  { name: "Github", pattern: "github.com/**" },
]);

const tags = ref(["Local", "Cloud"].join(","));

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-filter-tabs-glob.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const { localeIndex } = useData();
</script>

# Filtering

If your documentation grows to a certain size, or you have multiple sources (e.g., a webpage, GitHub, etc.), you'll need to filter the results.

Currently we have **two built-in components** for filtering.

## `canary-filter-tabs-glob`

[reference](/docs/reference/web#canary-filter-tabs-glob)

All providers support this type of filtering.

```html-vue
<canary-search slot="mode">
  <canary-filter-tabs-glob slot="head" tabs='{{ JSON.stringify(tabs) }}'> </canary-filter-tabs-glob> // [!code ++]
  <canary-search-results slot="body"></canary-search-results>
</canary-search>
```

<canary-root framework="vitepress" query="vitepress" v-if="loaded">
  <canary-provider-cloud :api-base="data.base" :project-key="data.key">
    <canary-content>
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-filter-tabs-glob slot="head" :tabs="JSON.stringify(tabs)"></canary-filter-tabs-glob>
        <canary-search-results slot="body"></canary-search-results>
      </canary-search>
    </canary-content>
  </canary-provider-cloud>
</canary-root>

## `canary-filter-tags`

[reference](/docs/reference/web#canary-filter-tags)

Two providers support this type of filtering.

- `canary-provider-cloud`
  - `tags` should be defined in our dashboard.
- `canary-provider-pagefind`
  - `data-pagefind-meta="tag"` should be available. Read more about it [here](https://pagefind.app/docs/metadata/).

```html-vue
<canary-content>
  <canary-input slot="input"></canary-input>
  <canary-search slot="mode">
    <canary-filter-tags slot="head" tags='{{ JSON.stringify(tags) }}'></canary-filter-tags> // [!code ++]
    <canary-search-results slot="body"></canary-search-results>
  </canary-search>
</canary-content>
```

<canary-root framework="vitepress" query="vitepress" v-if="loaded">
  <canary-provider-cloud :api-base="data.base" :project-key="data.key">
    <canary-content>
      <canary-filter-tags slot="head" :tags="tags"></canary-filter-tags>
      <canary-input slot="input"></canary-input>
      <canary-search slot="mode">
        <canary-search-results slot="body"></canary-search-results>
      </canary-search>
    </canary-content>
  </canary-provider-cloud>
</canary-root>

<style scoped>
  canary-root {
    --canary-content-max-width: 690px;
    --canary-content-max-height: 300px;
    --canary-color-primary-c: 0.05;
    --canary-color-primary-h: 90;
  }
</style>
