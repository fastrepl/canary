import { createBlurUp } from "@mux/blurup";

export default {
  async load() {
    const IDs = [];

    return Promise.all(
      IDs.map((id) => createBlurUp(id, {}).then((data) => ({ id, data }))),
    ).then((items) =>
      items.reduce((acc, item) => ({ ...acc, [item.id]: item.data }), {}),
    );
  },
};
