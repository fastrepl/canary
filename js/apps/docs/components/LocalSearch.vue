<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useData } from "vitepress";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch.js"),
    import("@getcanary/web/components/canary-modal.js"),
    import("@getcanary/web/components/canary-trigger-searchbar.js"),
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

const tabs = JSON.stringify([
  { name: "All", pattern: "**/*" },
  { name: "Local", pattern: "**/local/**" },
  { name: "Cloud", pattern: "**/cloud/**" },
]);
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto" v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-vitepress-minisearch :localeIndex="localeIndex">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-input slot="input" autofocus></canary-input>
            <canary-search slot="mode">
              <canary-filter-tabs-glob
                slot="head"
                :tabs="tabs"
              ></canary-filter-tabs-glob>
              <canary-search-results slot="body"></canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>
      </canary-provider-vitepress-minisearch>
    </canary-root>
  </div>
</template>

<style scoped>
canary-root {
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
