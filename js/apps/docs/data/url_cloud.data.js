export default {
  async load() {
    return process.env.NODE_ENV === "production"
      ? {
          base: "https://cloud.getcanary.dev",
          key: "pk_3nU5ydAaTWcoqbsuUNYoyqHa",
        }
      : {
          base: "http://localhost:4000",
          key: process.env.CANARY_API_KEY,
        };
  },
};
