export default {
  async load() {
    return process.env.NODE_ENV === "production"
      ? {
          base: "https://cloud.getcanary.dev",
          key: process.env.CANARY_API_KEY,
        }
      : {
          base: "https://cloud.getcanary.dev",
          key: "uHH8gCOBQxBW_LYBq59DtGetN9ivlNo-",
        };
  },
};
