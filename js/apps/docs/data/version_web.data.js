export default {
  async load() {
    const data = await fetch(
      "https://registry.npmjs.org/@getcanary/web/latest",
    ).then((res) => res.json());

    return { version: data.version };
  },
};
