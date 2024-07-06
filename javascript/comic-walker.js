const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const body = xpaths("//body")[0];
const header = document.createElement("div");
header.style.display = "none";
header.style.visibility = "hidden";
body.append(header);
const canvases = xpaths('//li[contains(@id, "splide01-slide")]//canvas');
for (const [idx, canvas] of canvases.entries()) {
  console.log("" + idx + "/" + (canvases.length - 1));
  const img = document.createElement("img");
  img.style.display = "none";
  img.src = await canvas.toDataURL("mutelu/org");
  header.append(img);
}
console.log("done");
