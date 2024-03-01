const xpaths = (path, root = document) => {
  const query = document.evaluate(
    path,
    root,
    null,
    XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,
    null
  );
  return Array(query.snapshotLength)
    .fill(0)
    .map((_, index) => query.snapshotItem(index));
};
for (const div of xpaths("//div[./canvas]")) {
  const img = xpaths("./img", div)[0];
  const canvas = xpaths("./canvas", div)[0];
  img.src = await canvas.toDataURL("mutelu/org");
  canvas.classList.add("hide");
}
xpaths("//div[./canvas].img").map((img) => {
  img.classList.remove("hide");
});
