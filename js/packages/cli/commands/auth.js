import http from "http";
import { spawn } from "child_process";
import { listen } from "async-listen";

import { Command } from "commander";
import { spinner } from "@clack/prompts";
import pc from "picocolors";

import { readConfigFromDisk, writeConfigToDisk, nanoid } from "../utils";

export const auth = new Command("auth");

class UserCancellationError extends Error {
  constructor(message) {
    super(message);
    this.name = "UserCancellationError";
  }
}

auth.command("whoami").action(() => {
  const { base } = auth.parent.opts();
  const { key } = readConfigFromDisk();
});

auth.command("login").action(async () => {
  const { base } = auth.parent.opts();

  const config = readConfigFromDisk();
  if (config) {
    console.log(`You are already logged in.`);
    process.exit(0);
  }

  const server = http.createServer();
  const { port } = await listen(server, 0, "127.0.0.1");

  const authPromise = new Promise((resolve, reject) => {
    server.on("request", (req, res) => {
      res.setHeader("Access-Control-Allow-Origin", "*");
      res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
      res.setHeader(
        "Access-Control-Allow-Headers",
        "Content-Type, Authorization",
      );

      if (req.method === "OPTIONS") {
        res.writeHead(200);
        res.end();
      } else if (req.method === "GET") {
        const parsedUrl = url.parse(req.url, true);
        const queryParams = parsedUrl.query;
        
        if (queryParams.cancelled) {
          res.writeHead(200);
          res.end();
          reject(new UserCancellationError("login cancelled by user"));
        } else {
          res.writeHead(200);
          res.end();
          resolve(queryParams);
        }
      } else {
        res.writeHead(405);
        res.end();
      }
    });
  });

  const s1 = spinner();
  s1.start();

  const code = nanoid();
  const redirect = `http://127.0.0.1:${port}`;
  const urlToOpen = new URL(`${base}/auth/devices`);
  urlToOpen.searchParams.append("code", code);
  urlToOpen.searchParams.append("redirect", redirect);

  spawn("open", [urlToOpen.toString()]);
  s1.stop(`Confirmation code: ${code}`);

  const s2 = spinner();
  s2.start(`Waiting for authentication (${pc.dim(urlToOpen.toString())})...`);

  try {
    const authData = await authPromise;
    writeConfigToDisk({ key: authData });

    server.close();
    process.exit(0);
  } catch (error) {
    if (error instanceof UserCancellationError) {
      s2.stop("Authentication cancelled.");

      server.close();
      process.exit(0);
    } else {
      s2.stop(`Authentication failed: ${error}`);

      server.close();
      process.exit(1);
    }
  } finally {
    server.close();
    process.exit(0);
  }
});

auth.command("logout").action(() => {
  const { base } = auth.parent.opts();
  const { key } = readConfigFromDisk();
});
