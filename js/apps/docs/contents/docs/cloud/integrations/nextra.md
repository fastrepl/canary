# Nextra

`Nextra` is a static site generator powered by `Next.js`.

## 3 steps to integrate

### Step 1: Install `@getcanary/web`

```bash
npm install @getcanary/web
```

### Step 2: Create search component

```js
import React from "react";

export default function CanarySearchBar() {
  const [loaded, setLoaded] = React.useState(false);

  React.useEffect(() => {
    Promise.all([
      import("@getcanary/web/components/canary-root.js"),
      import("@getcanary/web/components/canary-provider-cloud.js"),
      import("@getcanary/web/components/canary-modal.js"),
      import("@getcanary/web/components/canary-trigger-searchbar.js"),
      import("@getcanary/web/components/canary-content.js"),
      import("@getcanary/web/components/canary-input.js"),
      import("@getcanary/web/components/canary-search.js"),
      import("@getcanary/web/components/canary-search-results.js"),
    ]).then(() => {
      setLoaded(true);
    });
  }, []);

  if (!loaded) {
    return null;
  }
  
  return (
    <canary-root framework="nextra">
        <canary-provider-cloud api-key="KEY" api-base="https://cloud.getcanary.dev">
            <canary-modal>
                <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
                <canary-content slot="content">
                    <canary-input slot="input"></canary-input>
                    <canary-search slot="mode">
                        <canary-search-results slot="body"></canary-search-results>
                    </canary-search>
                </canary-content>
            </canary-modal>
        </canary-provider-cloud>
    </canary-root>
  )
}
```

### Step 3: Replace

https://nextra.site/docs/docs-theme/theme-configuration#search

::: code-group

```js [theme.config.jsx]
export default {
    search: {
        component: () => <CanarySearchBar />
    }
}
```

:::