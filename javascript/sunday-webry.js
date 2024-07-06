const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0) .map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const isTainted = (ctx) => { try { var dummy = ctx.toDataURL(); return false; } catch (err) { return err.code === 18; } };
const next = xpaths('//a[contains(@class,"page-navigation-forward")]')[0];
const my_pages = xpaths('//p[contains(@class,"page-area")]');
const header = xpaths('//section[contains(@class,"episode-header")]')[0];
for (const [idx, page] of my_pages.entries()) {
  if (page.classList.contains("align-right")) next.click();
  console.log("" + (idx + 1) + "/" + my_pages.length);
  do { await sleep(100); } while (document.evaluate("count(canvas)", page, null, XPathResult.NUMBER_TYPE, null).numberValue == 0);
  const canvas = document.evaluate("canvas", page, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  var count = 0;
  do { await sleep(100); ++count; } while (!isTainted(canvas) && count < 100);
  const img = document.createElement("img");
  img.src = canvas.toDataURL("mutelu/org");
  img.style.display = "none";
  header.append(img);
}
console.log("done");
