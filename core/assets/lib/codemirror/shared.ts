import { EditorView, keymap, lineNumbers } from "@codemirror/view";
import { history, historyKeymap, defaultKeymap } from "@codemirror/commands";
import { markdown, markdownLanguage } from "@codemirror/lang-markdown";
import { pythonLanguage } from "@codemirror/lang-python";
import { javascriptLanguage } from "@codemirror/lang-javascript";

const historyExtensions = [
  history(),
  keymap.of([...defaultKeymap, ...historyKeymap]),
];

const markdownExtensions = [
  markdown({
    base: markdownLanguage,
    completeHTMLTags: true,
    codeLanguages: (info: string) => {
      switch (info) {
        case "py":
        case "python":
          return pythonLanguage;
        default:
          return javascriptLanguage;
      }
    },
  }),
];

const lineExtensions = [lineNumbers(), EditorView.lineWrapping];

export const sharedExtensions = [
  ...lineExtensions,
  ...historyExtensions,
  ...markdownExtensions,
];
