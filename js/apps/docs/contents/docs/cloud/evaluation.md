<script setup>
import Chart from "@components/EvaluationChart.vue";

const data = [
  { version: "0.1.0", timestamp: "2023-05-01T00:00:00Z", score: 0.42, metadata: { note: "This is a test" } },
  { version: "0.1.1", timestamp: "2023-05-02T00:00:00Z", score: 0.66, metadata: { note: "This is a test" } },
  { version: "0.1.2", timestamp: "2023-05-03T00:00:00Z", score: 0.67, metadata: { note: "This is a test" } },
  { version: "0.1.3", timestamp: "2023-05-04T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.4", timestamp: "2023-05-05T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.5", timestamp: "2023-05-06T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.6", timestamp: "2023-05-07T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.7", timestamp: "2023-05-08T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.8", timestamp: "2023-05-09T00:00:00Z", score: 0.69, metadata: { note: "This is a test" } },
  { version: "0.1.9", timestamp: "2023-05-11T00:00:00Z", score: 0.89, metadata: { note: "This is a test" } },
]
</script>

# Evaluation

> These are mock data. Work in progress.

<Chart :items="data" />
