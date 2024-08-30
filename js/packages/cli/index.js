#!/usr/bin/env node

import { Command } from "commander";

import { name, version } from "./package.json";
import { init, auth } from "./commands";

const program = new Command();

program.name(name).version(version);
program.command("init").action(() => init().catch(console.error));
program.command("auth").action(() => auth().catch(console.error));
program.parse();
