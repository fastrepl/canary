<script setup lang="ts">
import { onMounted, ref, watch } from "vue";
import { useData } from "vitepress";

import Slider from "./Slider.vue";
import ThemeSwitch from "vitepress/dist/client/theme-default/components/VPSwitchAppearance.vue";

const { localeIndex } = useData();

const chroma = ref(0.1);
const hue = ref(250);
const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-provider-vitepress-minisearch.js"),
    import("@getcanary/web/components/canary-modal.js"),
    import("@getcanary/web/components/canary-trigger-searchbar.js"),
    import("@getcanary/web/components/canary-content.js"),
    import("@getcanary/web/components/canary-search.js"),
    import("@getcanary/web/components/canary-search-input.js"),
    import("@getcanary/web/components/canary-search-results.js"),
  ]).then(() => {
    loaded.value = true;
  });

  watch(
    [chroma, hue],
    ([c, h]) => {
      document.documentElement.style.setProperty(
        "--canary-color-primary-c",
        c.toString(),
      );
      document.documentElement.style.setProperty(
        "--canary-color-primary-h",
        h.toString(),
      );
    },
    { immediate: true },
  );
});
</script>

<template>
  <div class="flex flex-row gap-4 mb-6" v-if="loaded">
    <Slider
      :min="0"
      :max="0.3"
      :step="0.001"
      :value="chroma"
      @change="chroma = $event"
    />
    <Slider :min="0" :max="360" :step="1" :value="hue" @change="hue = $event" />
    <ThemeSwitch />
  </div>

  <canary-root framework="vitepress">
    <canary-provider-vitepress-minisearch :localeIndex="localeIndex">
      <div class="flex flex-col w-full items-center justify-center gap-4">
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-search slot="mode">
              <canary-search-input slot="input"></canary-search-input>
              <canary-search-results slot="results"> </canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>

        <canary-content slot="content" query="what is canary">
          <canary-search slot="mode">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"> </canary-search-results>
          </canary-search>
        </canary-content>
      </div>
    </canary-provider-vitepress-minisearch>
  </canary-root>
</template>
