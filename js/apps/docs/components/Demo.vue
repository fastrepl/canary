<script setup lang="ts">
import { onMounted, ref, watch } from "vue";
import { useData } from "vitepress";

const { localeIndex } = useData();

onMounted(() => {
  import("@getcanary/web/components/canary-root");
  import("@getcanary/web/components/canary-provider-vitepress-minisearch");
  import("@getcanary/web/components/canary-provider-mock");
  import("@getcanary/web/components/canary-modal");
  import("@getcanary/web/components/canary-trigger-searchbar");
  import("@getcanary/web/components/canary-content");
  import("@getcanary/web/components/canary-search");
  import("@getcanary/web/components/canary-search-input");
  import("@getcanary/web/components/canary-search-results");
});

import Slider from "./Slider.vue";
import ThemeSwitch from "vitepress/dist/client/theme-default/components/VPSwitchAppearance.vue";

const chroma = ref(0.1);
const hue = ref(250);

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
</script>

<template>
  <div class="flex flex-row gap-4 mb-6">
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
            <canary-search slot="search">
              <canary-search-input slot="input"></canary-search-input>
              <canary-search-results slot="results"> </canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>

        <canary-content slot="content" query="integrate">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"> </canary-search-results>
          </canary-search>
        </canary-content>
      </div>
    </canary-provider-vitepress-minisearch>
  </canary-root>
</template>
