<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useData } from "vitepress";
import { data } from "@data/url_cloud.data";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const { localeIndex } = useData();
</script>

# Conditional Callout

```html-vue
<canary-search slot="mode">
  <canary-callout-discord keywords="discord,community" url="https://discord.gg/Y8bJkzuQZU" slot="body"></canary-callout-discord> // [!code ++]
  <canary-search-results slot="body"></canary-search-results>
</canary-search>
```

<canary-root framework="vitepress" query="is there a discord channel?" v-if="loaded">
  <canary-provider-cloud :api-base="data.base" :project-key="data.key">
    <canary-content>
        <canary-input slot="input"></canary-input>
        <canary-search slot="mode">
          <canary-callout-discord slot="body"></canary-callout-discord>
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
