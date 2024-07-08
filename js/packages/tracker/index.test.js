import { test, expect } from "@playwright/test";

test("basic", async ({ page }) => {
  const calls = [];
  page.on("request", (req) => {
    if (req.url().includes("getcanary.dev")) {
      calls.push(req.url());
    }
  });

  page.on("console", (msg) => {
    console.log(msg.text());
  });

  await page.goto("https://playwright.dev/");
  await page.addScriptTag({ path: "./index.js" });
  await expect(page).toHaveTitle(/Playwright/);
  await page.waitForLoadState("networkidle");

  expect(calls).toEqual(["https://getcanary.dev/api/v1/analytics"]);
});
