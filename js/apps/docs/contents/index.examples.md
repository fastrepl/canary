<br/>

- `canary-search-results` vs `canary-search-results-tabs`

::: code-group

```js{6} [Simple search]
<canary-root framework="docusaurus">
    <canary-provider-pagefind>
        <canary-content>
            <canary-search slot="mode"> // [!code focus]
                <canary-search-input slot="input"></canary-search-input> // [!code focus]
                <canary-search-results slot="body"></canary-search-results>  // [!code focus]
            </canary-search> // [!code focus]
        </canary-content>
    </canary-provider-pagefind>
</canary-root>
```

```js{6} [Search with groups and tabs]
<canary-root framework="docusaurus">
    <canary-provider-pagefind>
        <canary-content>
            <canary-search slot="mode">
                <canary-search-input slot="input"></canary-search-input>
                <canary-search-results slot="body"></canary-search-results>  // [!code --]
                <canary-search-results-tabs slot="body" group></canary-search-results-tabs>  // [!code ++]
            </canary-search>
        </canary-content>
    </canary-provider-pagefind>
</canary-root>
```

:::

<br/>

- `canary-provider-*` vs `canary-provider-cloud`

::: code-group

```js{2,4} [Local search only]
<canary-root framework="docusaurus">
    <canary-provider-pagefind>
        {/* Rest of the code */}
    </canary-provider-pagefind>
</canary-root>
```

```js-vue [Using Canary cloud]
<canary-root framework="docusaurus">
    <canary-provider-pagefind> // [!code --]
        <canary-provider-cloud api-key="KEY" api-base="https://cloud.getcanary.dev"> // [!code ++]
            {/* Rest of the code */}
        </canary-provider-cloud> // [!code ++]
    </canary-provider-pagefind> // [!code --]
</canary-root>
```

:::
