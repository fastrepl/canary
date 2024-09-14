import React from "react";

import ErrorBoundary from "@docusaurus/ErrorBoundary";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import { usePluginData } from "@docusaurus/useGlobalData";

import Canary from "./Canary";

export default function Index() {
  const { siteConfig } = useDocusaurusContext();
  const [path, setPath] = React.useState("");

  React.useEffect(() => {
    setPath(`${siteConfig.baseUrl}pagefind/pagefind.js`);
  }, [siteConfig]);

  const { options } = usePluginData("docusaurus-theme-search-pagefind");
  const { styles, ...rest } = options;

  React.useEffect(() => {
    if (options.styles) {
      Object.entries(options.styles).forEach(([key, value]) => {
        document.body.style.setProperty(key, value);
      });
    }
  }, [options]);

  if (!path) {
    return null;
  }

  return (
    <ErrorBoundary
      fallback={({ error, tryAgain }) => (
        <div>
          <p>Canary crashed because: "{error.message}".</p>
          <p>
            Most likely, your production build will be fine.{" "}
            <pre>(docusaurus build && docusaurus serve)</pre>
          </p>
          <p>Here's what you can do:</p>
          <ul>
            <li>
              Try to <button onClick={tryAgain}>reload</button> the page.
            </li>
            <li>
              Run production build at least once: <pre>docusaurus build</pre>
            </li>
            <li>
              If the problem persists, please{" "}
              <a href="https://github.com/fastrepl/canary/issues/new">
                open an issue.
              </a>
            </li>
          </ul>
        </div>
      )}
    >
      <Canary options={{ ...rest, path: path }} />
    </ErrorBoundary>
  );
}
