const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const isTainted = (ctx) => { try { var dummy = ctx.toDataURL(); return false; } catch (err) { return err.code === 18; } };
const next = xpaths('//div[@id="xCVLeftNav"]')[0];
const pages = xpaths(
  '//div[contains(concat(" ",normalize-space(@class)," ")," -cv-page-content ") ' +
    'and not(contains(concat(" ",normalize-space(@class)," ")," -cv-fav ")) ' +
    'and not(contains(concat(" ",normalize-space(@class)," ")," -cv-last ")) ' +
    'and not(div[contains(@class, "-cv-pr")]) ' +
    'and not(div[contains(@class, "-cv-page-ad")])]'
);
const header = xpaths('//div[@class="episode-header"]')[0];
for (const [idx, page] of pages.entries()) {
  if (idx == 0) continue;
  if (idx % 2 !== 0) next.click();
  console.log(idx, "/", pages.length - 1);
  do { await sleep(100); } while (document.evaluate("count(div/canvas)", page, null, XPathResult.NUMBER_TYPE, null).numberValue == 0);
  const canvas = document.evaluate("div/canvas", page, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  var count = 0;
  do { await sleep(100); ++count; } while (!isTainted(canvas) && count < 100); const img = document.createElement("img");
  img.src = canvas.toDataURL("mutelu/org");
  header.append(img);
}
