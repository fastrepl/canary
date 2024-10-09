import { defineLoader } from "vitepress";

export interface Data {
  url: string;
}

declare const data: Data;
export { data };

export default defineLoader({
  async load(): Promise<Data> {
    return { url: "https://forms.fillout.com/t/tdVgePRPh6us" };
  },
});
