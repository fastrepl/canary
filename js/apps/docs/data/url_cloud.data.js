export default {
  async load() {
    const url =
      process.env.NODE_ENV === "production"
        ? "https://cloud.getcanary.dev"
        : "https://cloud.getcanary.dev";

    return { base: url, key: "pk_3nU5ydAaTWcoqbsuUNYoyqHa" };
  },
};
