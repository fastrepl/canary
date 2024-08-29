export default {
  async load() {
    const res = await fetch("https://cloud.getcanary.dev/api/v1/openapi");
    const data = res.json();
    return data;
  },
};
