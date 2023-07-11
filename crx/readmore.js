/*
const xpaths = (path) => {
  const query = document.evaluate(path, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index));
};
return xpaths('//div[contains(concat(" ",normalize-space(@class)," "), " chapter-content ")]/img[@data-src] | //div[contains(concat(" ",normalize-space(@class)," "), " full-image ")]/img[@src]').map((a) => a.dataset.src !== undefined ? a.dataset.src.replace(/\s/g, "") : a.src !== undefined ? a.src.replace(/\s/g, "") : undefined);
*/
