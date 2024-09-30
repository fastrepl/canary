import React from "react";

export default function Canary({ options }) {
  const [loaded, setLoaded] = React.useState(false);

  React.useEffect(() => {
    Promise.all(
      [
        import("@getcanary/web/components/canary-root"),
        import("@getcanary/web/components/canary-provider-pagefind"),
        import("@getcanary/web/components/canary-modal"),
        import("@getcanary/web/components/canary-trigger-searchbar"),
        import("@getcanary/web/components/canary-input"),
        import("@getcanary/web/components/canary-content"),
        import("@getcanary/web/components/canary-search"),
        import("@getcanary/web/components/canary-search-results"),
        options?.tabs?.length
          ? import("@getcanary/web/components/canary-filter-tabs-glob")
          : null,
      ].filter(Boolean),
    )
      .then(() => setLoaded(true))
      .catch((e) =>
        console.error("Maybe you forgot to install '@getcanary/web'?", e),
      );
  }, []);

  if (!loaded) {
    return null;
  }

  return (
    <canary-root framework="docusaurus">
      <canary-provider-pagefind options={JSON.stringify(options)}>
        <canary-modal>
          <canary-trigger-searchbar slot="trigger"></canary-trigger-searchbar>
          <canary-content slot="content">
            <canary-input slot="input"></canary-input>
            <canary-search slot="mode">
              {options?.tabs?.length ? (
                <canary-filter-tabs-glob
                  slot="head"
                  tabs={JSON.stringify(options.tabs)}
                ></canary-filter-tabs-glob>
              ) : null}
              <canary-search-results slot="body"></canary-search-results>
            </canary-search>
          </canary-content>
        </canary-modal>
      </canary-provider-pagefind>
    </canary-root>
  );
}
