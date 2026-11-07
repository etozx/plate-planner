# Plate Planner API

A Cloudflare Worker that gives the site two things:

- **`POST /chat`**: the Help assistant. It answers only questions about Plate Planner and its meals; anything else gets a fixed "I can only help with Plate Planner" reply.
- **`GET/PUT/DELETE /sync/:code`**: cloud sync of a browser's plans under a private 24-character code, stored in Cloudflare D1.

## Why it can't run up a bill

- It runs on the **Workers Free plan**. Workers AI gives 10,000 free "neurons" a day; on the free plan it simply stops for the day when they're used up (the site then says "The helper is resting"). There is no card on file to charge.
- Each visitor gets at most **6 help messages a minute** and **30 a day**, and replies are capped at 350 tokens.
- Only `https://etozx.github.io` (and `localhost` for testing) may call it.
- The model is `@cf/meta/llama-3.3-70b-instruct-fp8-fast` (about 100 messages a day within the free allowance). For roughly 5× more messages with simpler answers, change `MODEL` in `src/index.js` to `@cf/meta/llama-3.1-8b-instruct-fp8-fast`.

Free D1 limits: 5 million rows read and 100,000 rows written a day. Visitor IP addresses are never stored; they're hashed.

## Set up (one time)

1. Create a free account at https://dash.cloudflare.com/sign-up
2. In this folder:
   ```bash
   npm install
   npx wrangler login
   npx wrangler d1 create plate-planner
   ```
   Copy the `database_id` it prints into `wrangler.toml` (replace `REPLACE_WITH_DATABASE_ID`).
3. Create the tables and deploy:
   ```bash
   npx wrangler d1 execute plate-planner --remote --file=schema.sql
   npx wrangler deploy
   ```
   It prints a URL like `https://plate-planner-api.<your-name>.workers.dev`.
4. Put that URL in `../index.html` (`const API_URL = '...'`) and push. The Help button and "Sync between devices" appear once it's set.

## If you change the meals

The assistant's meal list is a copy of `FOODS` in `../index.html`, inside `MEALS` in `src/index.js`. Update it when meals change, then `npx wrangler deploy` again.

## Local testing

```bash
npx wrangler d1 execute plate-planner --local --file=schema.sql
npx wrangler dev --local --port 8787
```
Workers AI only runs on Cloudflare, so locally `/chat` answers `503 ai_unavailable`; sync works fully.
On Windows, if the folder path is very long, `workerd.exe` fails to start (260-character path limit): copy it somewhere short, set `MINIFLARE_WORKERD_PATH` to that copy, and add `--persist-to=<short folder>`.
