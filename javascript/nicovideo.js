const xpaths = (path) => {
  const query = document.evaluate(path, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const canvases = xpaths('//canvas[not(contains(@class, "canvas")) and not(contains(@class, "balloon"))]');
const header = xpaths('//div[@id="CommonHeader"]')[0];
for (const canvas of canvases) {
    const img = document.createElement("img");
    img.style.display = "none";
    img.src = canvas.toDataURL("mutelu/org");
    header.append(img);
}
