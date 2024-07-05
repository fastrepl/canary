<script lang="ts">
  import { onMount } from "svelte";
  import { clsx } from "clsx";

  import { EditorView } from "@codemirror/view";
  import { EditorState } from "@codemirror/state";
  import { sharedExtensions } from "$lib/codemirror/shared";

  // import type { Live } from "$lib/interfaces";
  // export let live: Live;

  let element: HTMLDivElement;
  let view: EditorView;

  onMount(() => {
    view = new EditorView({ parent: element });
    return () => view.destroy();
  });

  $: if (view) {
    view.setState(createEditorState());
  }

  const createEditorState = () => {
    return EditorState.create({
      doc: "",
      extensions: [...sharedExtensions],
    });
  };
</script>

<div
  bind:this={element}
  class={clsx([
    "h-[calc(100vh-110px)] overflow-y-auto",
    "text-lg",
    "border border-gray-200 rounded-md bg-[#2E3235]",
  ])}
/>
