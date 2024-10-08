<script setup lang="ts">
import { useData } from "vitepress";

const { frontmatter } = useData();
const format = (date: string) => {
  return new Date(date).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  });
};
</script>

<template>
  <h1 class="text-2xl font-semibold">{{ frontmatter.title }}</h1>
  <div class="text-sm text-gray-500 mt-2 mb-6 flex flex-row gap-2">
    {{ format(frontmatter.date) }}, {{ frontmatter.author }}
  </div>
</template>
