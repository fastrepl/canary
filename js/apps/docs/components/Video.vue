<script>
import "@mux/mux-player";
import { data } from "../data/mux_video.data.js";

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
  <mux-player
    controls
    :playback-id="id"
    :style="{ 'aspect-ratio': videoData.aspectRatio }"
  >
    <img slot="poster" :src="videoData.posterUrl" :style="posterStyle" />
  </mux-player>
</template>
