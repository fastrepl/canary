<script setup lang="ts">
import { onMounted, onUnmounted, ref } from "vue";
import VPNavBarSearchButton from "vitepress/dist/client/theme-default/components/VPNavBarSearchButton.vue";

import { data } from "@data/url_cloud.data";

const trigger = ref(null);
const loaded = ref(false);

const handleKeydown = (e: KeyboardEvent) => {
  if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
    e.preventDefault();
    trigger.value.click();
  }
};

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-cloud.js"),
    import("@getcanary/web/components/canary-modal.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-input.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-mode-breadcrumb.js"),
    import("@getcanary/web/components/canary-filter-tabs-glob.js"),
    import("@getcanary/web/components/canary-filter-tags.js"),
    import("@getcanary/web/components/canary-search-match-github-issue.js"),
    import("@getcanary/web/components/canary-footer.js"),
  ]).then(() => {
    loaded.value = true;
  });

  document.addEventListener("keydown", handleKeydown);
});

onUnmounted(() => {
  document.removeEventListener("keydown", handleKeydown);
});

const tags = ["Local", "Cloud"].join(",");
const tabs = JSON.stringify([
  { name: "Docs", pattern: "**/getcanary.dev/**" },
  { name: "Github", pattern: "**/github.com/**" },
]);
const sync = JSON.stringify([
  { tag: "Local", pattern: "**/docs/local/**" },
  { tag: "Cloud", pattern: "**/docs/cloud/**" },
]);
const sources = ["canary_webpage", "canary_issue"];
</script>

<template>
  <div v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-cloud :project-key="data.key" :api-base="data.base">
        <canary-modal transition>
          <div ref="trigger" slot="trigger">
            <VPNavBarSearchButton />
          </div>
          <canary-content slot="content">
            <canary-filter-tags
              slot="head"
              :tags="tags"
              :url-sync="sync"
            ></canary-filter-tags>
            <canary-input slot="input" autofocus></canary-input>
            <canary-search slot="mode">
              <canary-callout-discord
                slot="head"
                url="https://discord.gg/Y8bJkzuQZU"
              ></canary-callout-discord>
              <canary-filter-tabs-glob
                slot="head"
                :tabs="tabs"
              ></canary-filter-tabs-glob>
              <canary-search-results
                slot="body"
                :tabs="tabs"
              ></canary-search-results>
            </canary-search>
            <canary-ask slot="mode">
              <canary-ask-results slot="body"></canary-ask-results>
            </canary-ask>
            <canary-footer slot="footer"></canary-footer>
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

@media (min-width: 768px) {
  .DocSearch-Button {
    background-color: var(--vp-c-bg-alt) !important;
  }
}
</style>
