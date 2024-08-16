<script setup lang="ts">
import { onMounted, ref, watch } from "vue";

import Slider from "./Slider.vue";
import ThemeSwitch from "vitepress/dist/client/theme-default/components/VPSwitchAppearance.vue";

onMounted(() => {
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

const chroma = ref(0.05);
const hue = ref(280);
</script>

<template>
  <div class="flex flex-row gap-4">
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
</template>
