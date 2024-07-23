<script setup lang="ts">
import { onMounted, ref, watch } from "vue";

onMounted(async () => {
  import("@getcanary/web/components/canary-styles-default");
  import("@getcanary/web/components/canary-provider-mock");
  import("@getcanary/web/components/canary-trigger-searchbar");
  import("@getcanary/web/components/canary-content");
  import("@getcanary/web/components/canary-search");
  import("@getcanary/web/components/canary-search-input");
  import("@getcanary/web/components/canary-search-results");
  import("@getcanary/web/components/canary-ask");
  import("@getcanary/web/components/canary-ask-input");
  import("@getcanary/web/components/canary-ask-results");
  import("@getcanary/web/components/canary-modal");
});

import Slider from "./Slider.vue";
import ThemeSwitch from "vitepress/dist/client/theme-default/components/VPSwitchAppearance.vue";

const chroma = ref(0.1);
const hue = ref(250);

watch(
  [chroma, hue],
  ([c, h]) => {
    document.documentElement.style.setProperty("--canary-color-primary-c", c);
    document.documentElement.style.setProperty("--canary-color-primary-h", h);
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

  <canary-provider-mock>
    <div class="flex flex-col w-full items-center justify-center gap-4">
      <canary-modal>
        <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
        <canary-content slot="content">
          <canary-search slot="search">
            <canary-search-input slot="input"></canary-search-input>
            <canary-search-results slot="results"></canary-search-results>
          </canary-search>
          <canary-ask slot="ask">
            <canary-ask-input slot="input"></canary-ask-input>
            <canary-ask-results slot="results"></canary-ask-results>
          </canary-ask>
        </canary-content>
      </canary-modal>

      <canary-content query="why use Canary?">
        <canary-search slot="search">
          <canary-search-input slot="input"></canary-search-input>
          <canary-search-results slot="results"></canary-search-results>
        </canary-search>
        <canary-ask slot="ask">
          <canary-ask-input slot="input"></canary-ask-input>
          <canary-ask-results slot="results"></canary-ask-results>
        </canary-ask>
      </canary-content>
    </div>
  </canary-provider-mock>
</template>
