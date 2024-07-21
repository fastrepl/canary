# Concepts

## Operation

You can build your own search-bar with Canary, and enable `search` only, `ask` only, or both.

### Search

This is traditional search.

### Ask

This does multi-step hybrid search to retrieve relevant documents, and generate answer with language model.

## Provider

`provider` is top-level wrapper components that provides way to perform the actual `operation`.
Currently we have three providers.

### `canary-provider-mock`

It mocks the operations and returns dummy data. Useful when trying out Canary in a sandbox.
[![stackBlitz](https://developer.stackblitz.com/img/open_in_stackblitz_small.svg)](https://stackblitz.com/edit/canary?file=index.html)

```html
<canary-provider-mock>
  <!-- Rest of the code -->
</canary-provider-mock>
```

### `canary-provider-pagefind`

This provider uses [Pagefind](https://pagefind.app/) to search the content.
Intended use-case is for drop-in replacement for [Starlight](https://starlight.astro.build/)'s default search bar.

```html
<canary-provider-pagefind baseUrl="https://docs.getcanary.dev">
  <!-- Rest of the code -->
</canary-provider-pagefind>
```

### `canary-provider-cloud`

This provider use our Canary backend to run operations. You can index your documentation and get public key from our hosted service at [cloud.getcanary.dev](https://cloud.getcanary.dev).

```html
<canary-provider-cloud
  key="YOUR_PUBLIC_KEY"
  endpoint="https://cloud.getcanary.dev"
>
  <!-- Rest of the code -->
</canary-provider-cloud>
```
