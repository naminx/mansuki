BEGIN TRANSACTION;
DROP TABLE IF EXISTS "webs";
CREATE TABLE IF NOT EXISTS "webs" (
  "web" INTEGER NOT NULL,
  "domain" TEXT NOT NULL CHECK("domain" <> '') UNIQUE,
  "last_visit" TEXT NOT NULL CHECK("last_visit" <> ''),
  "get_nth_page" TEXT,
  "get_comics" TEXT,
  "get_latest_chap" TEXT,
  "get_chapters" TEXT,
  "get_images" TEXT,
  PRIMARY KEY("web")
);
DROP TABLE IF EXISTS "comics";
CREATE TABLE IF NOT EXISTS "comics" (
  "comic" INTEGER NOT NULL,
  "title" TEXT NOT NULL CHECK("title" <> '') UNIQUE,
  "folder" TEXT NOT NULL CHECK("folder" <> '') COLLATE NOCASE UNIQUE,
  "volume" INTEGER NOT NULL,
  "chapter" TEXT NOT NULL,
  PRIMARY KEY("comic")
);
DROP TABLE IF EXISTS "urls";
CREATE TABLE IF NOT EXISTS "urls" (
  "comic" INTEGER NOT NULL,
  "web" INTEGER NOT NULL,
  "path" TEXT NOT NULL CHECK("path" <> ''),
  FOREIGN KEY("web") REFERENCES "webs"("web") ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY("comic") REFERENCES "comics"("comic") ON UPDATE CASCADE ON DELETE CASCADE,
  PRIMARY KEY("comic","web"),
  UNIQUE("web","path")
);
COMMIT;

