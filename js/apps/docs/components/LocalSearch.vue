<script setup lang="ts">
import { onMounted, ref } from "vue";
import { useData } from "vitepress";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch"),
    import("@getcanary/web/components/canary-modal"),
    import("@getcanary/web/components/canary-trigger-searchbar"),
    import("@getcanary/web/components/canary-content"),
    import("@getcanary/web/components/canary-search"),
    import("@getcanary/web/components/canary-search-input"),
    import("@getcanary/web/components/canary-search-results-group"),
  ]).then(() => {
    loaded.value = true;
  });
});

const { localeIndex } = useData();
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto" v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-vitepress-minisearch :localeIndex="localeIndex">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-search slot="search">
              <canary-search-input slot="input"></canary-search-input>
              <canary-search-results-group
                slot="results"
                groups="Docs:*;Cloud:/cloud/.+$"
              >
              </canary-search-results-group>
            </canary-search>
          </canary-content>
        </canary-modal>
      </canary-provider-vitepress-minisearch>
    </canary-root>
  </div>
</template>
