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
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
    import("@getcanary/web/components/canary-search-suggestions.js"),
    import("@getcanary/web/components/canary-callout-discord.js"),
    import("@getcanary/web/components/canary-ask.js"),
    import("@getcanary/web/components/canary-ask-input.js"),
    import("@getcanary/web/components/canary-ask-results.js"),
    import("@getcanary/web/components/canary-mode-breadcrumb.js"),
  ]).then(() => {
    loaded.value = true;
  });
});
</script>

<template>
  <div class="w-full max-w-[230px] pl-4 mr-auto" v-if="loaded">
    <canary-root framework="vitepress">
      <canary-provider-cloud :api-key="data.key" :api-base="data.base">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-search slot="mode">
              <canary-search-input slot="input" autofocus></canary-search-input>
              <canary-callout-discord
                slot="body"
                url="https://discord.gg/Y8bJkzuQZU"
              ></canary-callout-discord>
              <canary-search-suggestions
                slot="body"
              ></canary-search-suggestions>
              <canary-search-results slot="body"></canary-search-results>
            </canary-search>
            <canary-ask slot="mode">
              <canary-mode-breadcrumb
                slot="input-before"
                text="Ask AI"
              ></canary-mode-breadcrumb>
              <canary-ask-input slot="input"></canary-ask-input>
              <canary-ask-results slot="body"></canary-ask-results>
            </canary-ask>
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
