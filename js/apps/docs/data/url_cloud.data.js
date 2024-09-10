export default {
  async load() {
    return process.env.NODE_ENV === "production"
      ? {
          base: "https://cloud.getcanary.dev",
          key: process.env.CANARY_API_KEY,
        }
      : {
          base: "http://localhost:4000",
          key: process.env.CANARY_API_KEY,
        };
  },
};
