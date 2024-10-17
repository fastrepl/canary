import { createBlurUp } from "@mux/blurup";

export default {
  async load() {
    const IDs = [
      "hQVTgrdDzmoDOvrbpQdivP8IRUe5pqaXmnqgnTudGOQ",
      "nUOGm7YPkredG3iOTxl9dHZXe9b2UE62BGs3jVyPMps",
      "FcvYsU1UKh01UlN8kodhhgALWM001vXA74aAQuccKmStg",
    ];

    return Promise.all(
      IDs.map((id) => createBlurUp(id, {}).then((data) => ({ id, data }))),
    ).then((items) =>
      items.reduce((acc, item) => ({ ...acc, [item.id]: item.data }), {}),
    );
  },
};
