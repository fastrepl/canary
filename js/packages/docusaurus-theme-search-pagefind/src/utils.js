import fs from "fs";
import path from "path";

import micromatch from "micromatch";

// inspired by:
// https://github.com/praveenn77/docusaurus-lunr-search/blob/76c49c4/src/utils.js#L55
export const getFilePaths = (routesPaths, outDir, baseUrl, options) => {
  const { excludeRoutes = [], includeRoutes = [] } = options;

  const files = [];
  const addedFiles = new Set();

  for (const route of routesPaths) {
    if ([baseUrl, `${baseUrl}404.html`].includes(route)) {
      continue;
    }

    const relativePath = route.replace(baseUrl, "");

    const candidatePaths = [route, relativePath].flatMap((route) => [
      path.join(outDir, `${route}.html`),
      path.join(outDir, route, "index.html"),
    ]);

    const filePath = candidatePaths.find(fs.existsSync);

    if (filePath && !fs.existsSync(filePath)) {
      console.warn(
        `@getcanary/docusaurus-pagefind: could not resolve file for route '${route}', it will be missing in the search index`,
      );
      continue;
    }

    if (
      [
        addedFiles.has(filePath),
        includeRoutes.length > 0 &&
          !includeRoutes.some(
            (p) =>
              micromatch.isMatch(route, p) ||
              micromatch.isMatch(relativePath, p),
          ),
        excludeRoutes.some(
          (p) =>
            micromatch.isMatch(route, p) || micromatch.isMatch(relativePath, p),
        ),
      ].some(Boolean)
    ) {
      console.info(
        `'@getcanary/docusaurus-theme-search-pagefind': Skipping ${filePath}`,
      );
      continue;
    }

    files.push({ url: route, path: filePath });
    addedFiles.add(filePath);
  }

  return files;
};
