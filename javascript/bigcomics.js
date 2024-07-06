const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const isTainted = async (ctx) => { try { var dummy = await ctx.toDataURL(); return true; } catch (err) { return err.code === 18; } };
const next = xpaths('//div[@id="xCVLeftNav"]')[0];
const pages = xpaths("//div[@id='xCVPages']/div/div/div[@class='-cv-page-canvas']");
const header = xpaths('//div[@class="publish-date"]')[0];

for (const [idx, page] of pages.entries()) {
  // if (idx == 0) { continue; }
  if (idx % 2 !== 0) next.click();
  console.log("" + (idx + 1) + "/" + (pages.length));
  do { await sleep(100); } while (document.evaluate("count(canvas)", page, null, XPathResult.NUMBER_TYPE, null).numberValue == 0);
  const canvas = document.evaluate("canvas", page, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
  var count = 0;
  do { await sleep(100); ++count; } while (!(await isTainted(canvas)) && count < 100);
  const img = document.createElement("img");
  img.style.display = "none";
  img.src = canvas.toDataURL("mutelu/org");
  header.append(img);
}
console.log("done");
