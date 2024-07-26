import React from "react";

import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import { usePluginData } from "@docusaurus/useGlobalData";

import Canary from "./Canary";

export default function Index() {
  const { siteConfig } = useDocusaurusContext();
  const { options } = usePluginData("docusaurus-plugin-pagefind-canary");

  const [path, setPath] = React.useState("");

  React.useEffect(() => {
    setPath(`${siteConfig.baseUrl}pagefind/pagefind.js`);
  }, [siteConfig]);

  if (!path) {
    return null;
  }

  return <Canary options={{ ...options, path: path }} />;
}
