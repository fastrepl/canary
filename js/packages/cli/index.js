#!/usr/bin/env node

import { Command } from "commander";

import { name } from "./package.json";
import { init, auth, secrets } from "./commands";

const program = new Command();

program.name(name);
program.option(
  "--base [URL]",
  "base url for api requests",
  "https://cloud.getcanary.dev",
);
program.addCommand(init);
program.addCommand(auth);
program.addCommand(secrets);
program.parseAsync();
