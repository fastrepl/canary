<script setup lang="ts">
import { onMounted, ref, computed } from "vue";
import { useData } from "vitepress";

const loaded = ref(false);

const pattern = ref([{ name: "All", pattern: "**/*" }, { name: "Local", pattern: "**/local/**" }, { name: "Cloud", pattern: "**/cloud/**" }]);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results-tabs.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const { localeIndex } = useData();
</script>

# Spliting Tabs

```html-vue
<canary-search slot="mode">
  <canary-search-results slot="body"></canary-search-results> // [!code --]
  <canary-search-results-tabs tabs="{{ JSON.stringify(pattern) }}" slot="body">  // [!code ++]
  </canary-search-results-tabs>  // [!code ++]
</canary-search>
```

<canary-root framework="vitepress" query="⬇️ we have tabs below" v-if="loaded" :key="pattern">
  <canary-provider-vitepress-minisearch :localeIndex="localeIndex">
    <canary-content>
        <canary-input slot="input"></canary-input>
        <canary-search slot="mode">
          <canary-callout-discord slot="body"></canary-callout-discord>
          <canary-search-results-tabs
            slot="body"
            :tabs="JSON.stringify(pattern)"
          ></canary-search-results-tabs>
        </canary-search>
    </canary-content>
  </canary-provider-vitepress-minisearch>
</canary-root>

<style scoped>
  label {
    padding-top: 4px;
  }

  input {
    border: 1px solid var(--vp-c-text-3);
    border-radius: 6px;
    padding: 2px 4px;
    width: 320px;
  }

  canary-root {
    --canary-content-max-width: 690px;
    --canary-content-max-height: 300px;
    --canary-color-primary-c: 0.05;
    --canary-color-primary-h: 90;
  }
</style>
