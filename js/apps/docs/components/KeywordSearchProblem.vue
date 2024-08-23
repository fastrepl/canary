<script setup lang="ts">
type Side = {
  query: string;
  items: Array<{ title: string; excerpt: string }>;
  emoji: string;
};

const props = defineProps<{
  left: Side;
  right: Side;
}>();
</script>

<template>
  <div
    class="container w-full border rounded-md p-2 flex flex-row gap-4 justify-between"
  >
    <div
      v-for="side in ['left', 'right']"
      :key="side"
      class="flex flex-col gap-2 w-full"
    >
      <input
        type="text"
        :value="`🔎 ${props[side].query}|`"
        disabled
        class="border rounded-md w-full text-sm"
      />
      <div
        v-for="(item, index) in props[side].items"
        :key="index"
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span v-html="item.excerpt"></span>
        <span class="font-semibold" v-html="item.title"></span>
      </div>
      <span class="mt-auto mx-auto text-2xl">{{ props[side].emoji }}</span>
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
