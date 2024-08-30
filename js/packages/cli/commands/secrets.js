import { Command } from "commander";

import { readConfigFromDisk } from "../utils";

export const secrets = new Command("secrets");

secrets
  .command("set")
  .arguments("<key> <value>")
  .action((key, value) => {
    const { base } = secrets.parent.opts();
    const config = readConfigFromDisk();

    fetch(`${base}/api/v1/secrets/set`, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${config.key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ key, value }),
    });
  });

secrets
  .command("unset")
  .arguments("<key>")
  .action((key) => {
    const { base } = secrets.parent.opts();
    const config = readConfigFromDisk();

    fetch(`${base}/api/v1/secrets/unset/${key}`, {
      method: "GET",
      headers: {
        Authorization: `Bearer ${config.key}`,
      },
    });
  });

secrets.command("list").action(() => {
  const { base } = secrets.parent.opts();
  const config = readConfigFromDisk();

  fetch(`${base}/api/v1/secrets`, {
    method: "GET",
    headers: {
      Accept: "application/json",
      Authorization: `Bearer ${config.key}`,
    },
  });
});
