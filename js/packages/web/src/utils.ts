export const randomInteger = () => {
  return Math.floor(Math.random() * 1000000000000000);
};

export const urlToParts = (url: string) => {
  let paths: string[] = [];
  try {
    paths = new URL(url).pathname.split("/");
  } catch {
    paths = url.split("/");
  }

  const parts = paths
    .map((path, _) => {
      const text = path.replace(/[-_]/g, " ");
      return text.charAt(0).toUpperCase() + text.slice(1);
    })
    .map((text) => (text.includes("#") ? text.split("#")[0] : text))
    .map((text) => (text.endsWith(".html") ? text.replace(".html", "") : text))
    .filter(Boolean)
    .slice(-4);

  return parts;
};
