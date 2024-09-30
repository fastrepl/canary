<script setup lang="ts">
import { onMounted, ref } from "vue";
import { data } from "../data/mux_video.data.js";

const props = defineProps<{ id: string }>();

const loaded = ref(false);

onMounted(() => {
  Promise.all([
    import("@mux/mux-player"),
    import("@getcanary/web/components/canary-styles.js"),
  ]).then(() => {
    loaded.value = true;
  });
});

const videoData = data[props.id];
const posterStyle = {
  width: "100%",
  "background-size": "cover",
  "background-position": "center",
  "background-repeat": "no-repeat",
  "background-image": `url("${videoData.blurDataURL}")`,
};
</script>

<template>
  <canary-styles v-if="loaded">
    <mux-player
      controls
      :playback-id="props.id"
      :style="{ 'aspect-ratio': videoData.aspectRatio }"
      accent-color="var(--canary-color-primary-80)"
    >
      <img slot="poster" :src="videoData.posterUrl" :style="posterStyle" />
    </mux-player>
  </canary-styles>
</template>

<style scoped>
canary-styles {
  --canary-color-primary-c: 0.05;
  --canary-color-primary-h: 90;
}
</style>
