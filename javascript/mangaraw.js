const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const isTainted = (ctx) => { try { var dummy = ctx.toDataURL(); return false; } catch (err) { return err.code === 18; } };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const header = xpaths('//body')[0];
for (const div of xpaths('(//div[contains(concat(" ", normalize-space(@class), " "), " chapter-lazy ")])')) {
  div.scrollIntoView();
  do { await sleep(100); } while (document.evaluate("count(canvas)", div, null, XPathResult.NUMBER_TYPE, null).numberValue == 0);
  const canvas = xpaths("canvas", div)[0];
  do { await sleep(100); } while (!isTainted(canvas));
  const img = document.createElement("img");
  img.style.display = "none";
  img.src = await canvas.toDataURL("mutelu/org");
  header.append(img);
}
