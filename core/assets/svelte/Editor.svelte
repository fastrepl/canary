<script lang="ts">
  import { onMount } from "svelte";
  import { clsx } from "clsx";
  import { EditorView } from "@codemirror/view";

  import type { Live } from "$lib/interfaces";

  export let live: Live;

  let element: HTMLDivElement;
  let view: EditorView;

  onMount(() => {
    view = new EditorView({ parent: element });
    return () => view.destroy();
  });
</script>

<div
  bind:this={element}
  class={clsx([
    "h-[calc(100vh-75px)] overflow-y-auto",
    "text-lg selection:bg-[#fef16033]",
    "border-b border-x border-gray-200 rounded-b-lg bg-gray-50",
  ])}
/>
