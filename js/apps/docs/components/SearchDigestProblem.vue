<script setup lang="ts">
const props = defineProps<{
  query: string;
  items: Array<{ excerpt: string; title: string }>;
}>();
</script>

<template>
  <div
    class="container w-full border rounded-md p-2 flex flex-row gap-8 justify-between"
  >
    <div class="flex flex-col gap-2 w-full">
      <input
        type="text"
        :value="`🔎 ${props.query}|`"
        disabled
        class="border rounded-md w-full"
      />
      <div
        v-for="(item, index) in props.items"
        :key="index"
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span v-html="item.excerpt"></span>
        <span class="font-semibold" v-html="item.title"></span>
      </div>
      <span class="mx-auto">・・・</span>
    </div>
  </div>
</template>

<style scoped>
.container {
  background-color: var(--vp-sidebar-bg-color);
  border-color: var(--vp-c-divider);
}

input {
  color: var(--vp-c-text-1);
  border-color: red;
  background-color: var(--vp-c-bg);
  padding: 4px 8px;
}

.item {
  background-color: var(--vp-c-bg-soft);
  border-color: var(--vp-c-divider);
}
</style>
