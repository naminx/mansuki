const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const xpath = (path, root) => document.evaluate(path, root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
String.prototype.hasClass = function (anyClass) { return `${this}[contains(concat(" ", normalize-space(@class), " "), " ${anyClass} ")]`; };
return xpaths('//div'.hasClass("item-summary")).map((div) => { return {
  url: xpath("./div".hasClass("post-title") + "/h3/a", div).href,
  chapter: xpath(".//span".hasClass("chapter"), div).textContent.replace(/.*第([^第]+)話.*/, "$1"), }; });

/
