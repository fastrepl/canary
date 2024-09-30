<script>
import "@mux/mux-player";
import { data } from "../data/mux_video.data.js";
import "@getcanary/web/components/canary-styles.js";

export default {
  name: "Video",
  props: {
    id: {
      type: String,
      required: true,
    },
  },
  computed: {
    videoData() {
      return data[this.id];
    },
    posterStyle() {
      return {
        width: "100%",
        "background-size": "cover",
        "background-position": "center",
        "background-repeat": "no-repeat",
        "background-image": `url("${this.videoData.blurDataURL}")`,
      };
    },
  },
};
</script>

<template>
  <canary-styles>
    <mux-player
      controls
      :playback-id="id"
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
