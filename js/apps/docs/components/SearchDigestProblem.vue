<template>
  <div
    class="container w-full h-[260px] border rounded-md p-2 flex flex-row gap-8 justify-between"
  >
    <div class="flex flex-col gap-2 w-full">
      <input
        type="text"
        value="🔎 config feature_a|"
        disabled
        class="border rounded-md w-full"
      />
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span
          ><mark>feature_a</mark>: option_1, option_2, option_3, option_4,
          option_5...</span
        >
        <span class="font-semibold">Reference - <mark>config</mark>.yaml</span>
      </div>
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span
          >...<mark>feature_a</mark>is really good. there's 999 ways of doing...
        </span>
        <span class="font-semibold">What is <mark>Feature_A</mark>?</span>
      </div>
      <div
        class="item w-full border rounded-md p-2 text-xs flex flex-col gap-1"
      >
        <span
          >...to configure options for <mark>feature_a</mark>, you shoud do this
          and that...
        </span>
        <span class="font-semibold">Tutorial - <mark>Config</mark>uration</span>
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
