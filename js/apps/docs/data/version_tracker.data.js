export default {
  async load() {
    const data = await fetch(
      "https://registry.npmjs.org/@getcanary/tracker/latest",
    ).then((res) => res.json());

    return { version: data.version };
  },
};
