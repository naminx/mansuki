const xpaths = (path) => {
  const query = document.evaluate(path, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const body = xpaths('//body')[0];
const isTainted = (ctx) => { try { var dummy = ctx.toDataURL(); return false; } catch (err) { return err.code === 18; } };
for (const canvas of xpaths('//div[@class="img-container"]/canvas')) {
  canvas.scrollIntoView();
  while (!isTainted(canvas)) await sleep(1000);
  const img = document.createElement("img");
  img.style.display = "none";
  img.src = await canvas.toDataURL("mutelu/org");
  body.append(img);
}
return xpaths('//body/img').map((img) => img.src);
