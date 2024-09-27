<script setup lang="ts">
import { onMounted, ref } from "vue";
import { data } from "../data/url_cloud.data.js";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-modal.js"),
    import("@getcanary/web/components/canary-trigger-searchbar.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-search-suggestions.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-mode-breadcrumb.js"),
    import("@getcanary/web/components/canary-filter-tabs-glob.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const tabs = JSON.stringify([
  { name: "All", pattern: "**/*" },
  { name: "Local", pattern: "**/local/**" },
  { name: "Cloud", pattern: "**/cloud/**" },
]);
const sources = ["canary_webpage", "canary_issue"];
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto" v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-cloud
        :api-key="data.key"
        :api-base="data.base"
        :sources="sources"
      >
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-input slot="input" autofocus></canary-input>
            <canary-search slot="mode">
              <canary-callout-discord
                slot="body"
                url="https://discord.gg/Y8bJkzuQZU"
              ></canary-callout-discord>
              <canary-filter-tabs-glob
                slot="body"
                :tabs="tabs"
              ></canary-filter-tabs-glob>
              <canary-search-suggestions
                slot="body"
              ></canary-search-suggestions>
              <canary-search-results
                slot="body"
                :tabs="tabs"
              ></canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>
      </canary-provider-cloud>
    </canary-root>
  </div>
</template>

<style scoped>
canary-root {
  --canary-content-max-width: 650px;
  --canary-content-max-height: 500px;
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
