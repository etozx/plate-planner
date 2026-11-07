-- Plate Planner API tables (Cloudflare D1)
CREATE TABLE IF NOT EXISTS plans (
  code TEXT PRIMARY KEY,          -- private sync code chosen by the browser (24 random characters)
  data TEXT NOT NULL,             -- JSON: the browser's plate-* storage keys
  updated_at INTEGER NOT NULL     -- ms since epoch
);
CREATE TABLE IF NOT EXISTS ai_usage (
  day TEXT NOT NULL,              -- YYYY-MM-DD (UTC)
  who TEXT NOT NULL,              -- hashed visitor IP, never the raw address
  n INTEGER NOT NULL,
  PRIMARY KEY (day, who)
);
