const xpaths = (path) => {
  const query = document.evaluate(path, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
return xpaths('//div[@class="img-container"]/img').map((img) => img.src);
