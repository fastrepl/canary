<script setup lang="ts">
import { onMounted, ref, watch } from "vue";

import Slider from "./Slider.vue";
import ThemeSwitch from "vitepress/dist/client/theme-default/components/VPSwitchAppearance.vue";

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@getcanary/web/components/canary-root.js"),
    import("@getcanary/web/components/canary-reference.js"),
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

const chroma = ref(0.1);
const hue = ref(250);
</script>

<template>
  <div class="flex flex-col gap-2" v-if="loaded">
    <div class="flex flex-col gap-1 my-4 font-mono">
      <span>--canary-color-primary-c: {{ chroma.toFixed(2) }}</span>
      <span>--canary-color-primary-h: {{ hue }}</span>
    </div>

    <div class="flex flex-row gap-4 mb-6">
      <Slider
        :min="0"
        :max="0.3"
        :step="0.001"
        :value="chroma"
        @change="chroma = $event"
      />
      <Slider
        :min="0"
        :max="360"
        :step="1"
        :value="hue"
        @change="hue = $event"
      />
      <ThemeSwitch />
    </div>

    <canary-root framework="vitepress">
      <canary-reference
        url="https://example.com/docs/facilisi/odio"
        title="Tincidunt pretium varius"
        excerpt="Lorem ipsum odor amet, <mark>consectetuer</mark> adipiscing elit."
        selected
      ></canary-reference>
    </canary-root>
  </div>
</template>
