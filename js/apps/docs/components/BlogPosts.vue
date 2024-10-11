<script setup lang="ts">
import { data as posts } from "@data/blog_posts.data";
</script>

<template>
  <ul>
    <a :href="post.url" v-for="post of posts">
      <li class="flex justify-between">
        <span>{{ post.title }}</span>
        <span class="text-sm leading-loose">{{ post.date.string }}</span>
      </li>
    </a>
  </ul>
</template>

<style scoped src="@unocss/reset/tailwind-compat.css"></style>
<style scoped>
ul {
  margin-top: 36px;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

li {
  cursor: pointer;
  padding: 16px 12px 12px 12px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background-color: var(--vp-c-bg-soft);
}
li:hover {
  background-color: var(--vp-custom-block-warning-bg);
}

a {
  color: var(--vp-c-text-1);
  font-size: 1.2rem;
  font-weight: 400;
}
a:hover {
  color: var(--vp-c-text-1);
}
</style>
