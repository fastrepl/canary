<template>
  <Bubble :data="chartData" :options="chartOptions" />
</template>

<script lang="ts">
import { Bubble } from "vue-chartjs";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BubbleController,
  LinearScale,
  CategoryScale,
  PointElement,
  ChartOptions,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BubbleController,
  LinearScale,
  CategoryScale,
  PointElement,
);

import { useData } from "vitepress";
import { format } from "timeago.js";
import type { EvaluationResult } from "./types";

export default {
  name: "EvaluationChart",
  components: { Bubble },
  props: {
    title: {
      type: String,
      required: false,
    },
    items: {
      type: Array<EvaluationResult>,
      required: true,
    },
  },
  setup() {
    const { isDark } = useData();
    return { isDark };
  },
  computed: {
    chartData() {
      return {
        datasets: [
          {
            label: "Evaluation Scores",
            data: this.items
              .sort(
                (a: EvaluationResult, b: EvaluationResult) =>
                  new Date(a.timestamp).getTime() -
                  new Date(b.timestamp).getTime(),
              )
              .map((item: EvaluationResult) => ({
                x: item.version,
                y: item.score,
                r: 6,
                metadata: { ...item.metadata, timestamp: item.timestamp },
              })),
            backgroundColor: this.isDark
              ? "rgba(255, 255, 255, 0.2)"
              : "rgba(0, 0, 0, 0.2)",
            borderColor: this.isDark
              ? "rgba(255, 255, 255, 0.8)"
              : "rgba(0, 0, 0, 0.8)",
            borderWidth: 1,
          },
        ],
      };
    },
    chartOptions(): ChartOptions<"bubble"> {
      return {
        responsive: true,
        plugins: {
          legend: {
            display: false,
          },
          title: {
            display: !!this.title,
            text: this.title,
            color: this.isDark ? "#ffffff" : "#000000",
          },
          tooltip: {
            callbacks: {
              title: ([item]) => {
                const version = item.raw["x"];
                const { timestamp } = item.raw["metadata"];
                return `${version} (${format(timestamp, "en_US")})`;
              },
              label: (context) => {
                const score = context.raw["y"];
                const { timestamp, ..._rest } = context.raw["metadata"];
                return [score];
              },
            },
          },
        },
        scales: {
          x: {
            type: "category",
            title: {
              display: true,
              text: "Version",
              color: this.isDark ? "#ffffff" : "#000000",
            },
            ticks: {
              color: this.isDark ? "#ffffff" : "#000000",
            },
            grid: {
              color: this.isDark
                ? "rgba(255, 255, 255, 0.1)"
                : "rgba(0, 0, 0, 0.1)",
            },
          },
          y: {
            title: {
              display: false,
              text: "Score",
              color: this.isDark ? "#ffffff" : "#000000",
            },
            ticks: {
              display: false,
              color: this.isDark ? "#ffffff" : "#000000",
            },
            grid: {
              color: this.isDark
                ? "rgba(255, 255, 255, 0.1)"
                : "rgba(0, 0, 0, 0.1)",
            },
            min: 0,
            max: 1,
          },
        },
      };
    },
  },
};
</script>
