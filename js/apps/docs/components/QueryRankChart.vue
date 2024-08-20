<template>
  <Bar :data="chartData" :options="chartOptions" />
</template>

<script>
import { Bar } from "vue-chartjs";
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
} from "chart.js";

ChartJS.register(
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale,
);

import { useData } from "vitepress";

export default {
  name: "BarChart",
  components: { Bar },
  props: {
    title: {
      type: String,
      default: "",
    },
    labels: {
      type: Array,
      required: true,
    },
    values: {
      type: Array,
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
        labels: this.labels,
        datasets: [
          {
            data: this.values,
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
    chartOptions() {
      return {
        indexAxis: "y",
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
              label: (context) => `${context.parsed.x}`,
            },
          },
        },
        scales: {
          x: {
            ticks: {
              display: false,
              color: this.isDark ? "#ffffff" : "#000000",
            },
            grid: {
              color: this.isDark
                ? "rgba(255, 255, 255, 0.1)"
                : "rgba(0, 0, 0, 0.1)",
            },
          },
          y: {
            ticks: {
              color: this.isDark ? "#ffffff" : "#000000",
              callback: (value, index) => this.labels[index],
            },
            grid: {
              color: this.isDark
                ? "rgba(255, 255, 255, 0.1)"
                : "rgba(0, 0, 0, 0.1)",
            },
          },
        },
      };
    },
  },
};
</script>
