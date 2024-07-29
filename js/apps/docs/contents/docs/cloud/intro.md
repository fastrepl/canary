# Canary Cloud

> Canary Cloud is in active development. Not ready for production use yet.

`Canary` works great with local search index. But at some point, you'll need additional features that require talking to a server. `canary-provider-cloud` aims to provide that.

Switching should be straightforward:

```html
<canary-root framework="...">
  <canary-provider-SOMETHING> // [!code --]
    <canary-provider-cloud // [!code ++]
      key="YOUR_PUBLIC_KEY" // [!code ++]
      endpoint="https://cloud.getcanary.dev" // [!code ++]
    > // [!code ++]
      <!-- Rest of the code -->
    </canary-provider-cloud> // [!code ++]
  </canary-provider-SOMETHING> // [!code --]
</canary-root>
```

## Hosted Search Index

Better search performance.

## Complex Query Understanding

Using language model to understand questions and generate answers.

## Documentation Analytics

From user's interactions with the documentation, `Canary` provide insights on how to improve the documentation.
