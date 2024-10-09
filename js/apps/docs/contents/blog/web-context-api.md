---
title: Building Plugins in the DOM with Web Components
date: 2024-10-08
author: Yujong Lee
draft: false

next: false
sidebar: false
editLink: false
lastUpdated: false
---

<script setup lang="ts">
  import BlogPostHeader from '@components/BlogPostHeader.vue'
</script>

<BlogPostHeader />

At [🐤Canary](/), we provide a set of web components for building a search-bar.

When I first started writing this, I didn't have strong opinions on the implementation details. However, an important requirement is that **users should be able to use the same UI components for both local and hosted search.**

So it should look something like this:

::: code-group

<!-- prettier-ignore -->
```html [Local search]
<canary-root>
  <canary-provider-pagefind> // [!code ++]
    <canary-search></canary-search>
  </canary-provider-pagefind> // [!code ++]
</canary-root>
```

<!-- prettier-ignore -->
```html [Hosted search]
<canary-root>
  <canary-provider-cloud> // [!code ++]
    <canary-search></canary-search>
  </canary-provider-cloud> // [!code ++]
</canary-root>
```

:::

Overtime, this idea evolved and enabled interesting plugin-like API for building a search-bar.

Specifically, we're using [Context Protocol](https://github.com/webcomponents-cg/community-protocols/blob/main/proposals/context.md) and [Lit Components](https://lit.dev/docs/data/context/).

## Why we need Context

When building components that are intended to be **1. consumed by others,** and **2. allow swapping out parts using children or slots,** we can not use `props` to pass data.

::: code-group

```jsx [1]
function Parent() {
  return (
    <div>
      <Child data="data" />
    </div>
  );
}

// We can only use it like: <Parent />
```

```jsx [2]
function Parent({ children }) {
  return <div>{children}</div>;
}

// We can only use it like: <Parent />
```

:::

## Problem

```html

```

- Also, additional features, like `Ask AI`, should be **easy to opt-in.** ↓

::: code-group

<!-- prettier-ignore -->
```html [Search only]
<canary-root>
  <canary-search></canary-search> // [!code ++]
</canary-root>
```

<!-- prettier-ignore -->
```html [Search + Ask]
<canary-root>
  <canary-search></canary-search> // [!code ++]
  <canary-ask></canary-ask> // [!code ++]
</canary-root>
```

:::

- Also, additional features, like `Ask AI`, should be **easy to opt-in.** ↓

::: code-group

<!-- prettier-ignore -->
```html [Search only]
<canary-root>
  <canary-search></canary-search> // [!code ++]
</canary-root>
```

<!-- prettier-ignore -->
```html [Search + Ask]
<canary-root>
  <canary-search></canary-search> // [!code ++]
  <canary-ask></canary-ask> // [!code ++]
</canary-root>
```

:::

## Solution

https://vuejs.org/guide/extras/web-components

https://lit.dev/docs/data/context/

https://custom-elements-everywhere.com/

https://svelte.dev/repl/63a1a1fad70644e6a2b082c86a5dab03?version=4.2.19

https://github.com/blikblum/wc-context

## How about...?

Here I will list some other approaches that are related to web-components, but still interesting to touch on.

### React Context

https://react.dev/learn/passing-data-deeply-with-context#context-an-alternative-to-passing-props

Why not?

- we don't have to ship react.
- yes - preact is small..

### Svelte Store

### Svelte Slot Props

**Svelte** has something cool called [slot props](https://svelte.dev/tutorial/slot-props).

::: code-group

```svelte{6} [App.svelte]
<script>
	import Parent from "./Parent.svelte"
	import Child from "./Child.svelte"
</script>

<Parent let:data={data}>
	<Child data={data}/>
</Parent>
```

```svelte{7} [Parent.svelte]
<script>
	const data = "data";
</script>

<div>
	<div>parent</div>
	<slot data={data} />
</div>
```

```svelte [Child.svelte]
<script>
	export let data;
</script>

<div>
	<div>child</div>
	<div>{data}</div>
</div>
```

:::

But none of above approaches are appealing, for few reasons:

1. We want web-component. Bundle size, web standard, etc.
2. Svelte can be compiled to web-components, but there's [some quirks](https://github.com/sveltejs/svelte/issues/8826#issuecomment-2173278529)
3. Even if svelte is able to compile to web-components without any problem, its still specific framework's implementation. we want framework-agnostic solution.
