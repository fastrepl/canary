import BrowserOnly from "@docusaurus/BrowserOnly";
import Search from "./Search";

export default function Index() {
  return <BrowserOnly>{() => <Search />}</BrowserOnly>;
}
