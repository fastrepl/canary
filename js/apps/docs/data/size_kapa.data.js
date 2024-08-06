export default {
  async load() {
    const data = await fetch(
      "https://widget.kapa.ai/kapa-widget.bundle.js",
    ).then((res) => res.text());

    return { size: Math.round(data.length / 1024) };
  },
};
