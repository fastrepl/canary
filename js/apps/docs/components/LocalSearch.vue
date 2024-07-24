<script setup lang="ts">
import { onMounted } from "vue";
import { useData } from "vitepress";

onMounted(() => {
  import("@getcanary/web/components/canary-styles-default");
  import("@getcanary/web/components/canary-provider-vitepress-minisearch");
  import("@getcanary/web/components/canary-modal");
  import("@getcanary/web/components/canary-trigger-searchbar");
  import("@getcanary/web/components/canary-content");
  import("@getcanary/web/components/canary-search");
  import("@getcanary/web/components/canary-search-input");
  import("@getcanary/web/components/canary-search-results");
});

const { localeIndex } = useData();
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto">
    <canary-styles-default framework="vitepress">
      <canary-provider-vitepress-minisearch :localeIndex="localeIndex">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-search slot="search">
              <canary-search-input slot="input"></canary-search-input>
              <canary-search-results slot="results"></canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>
      </canary-provider-vitepress-minisearch>
    </canary-styles-default>
  </div>
</template>
