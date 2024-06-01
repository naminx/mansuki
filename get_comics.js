const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const xpath = (path, root) => document.evaluate(path, root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
String.prototype.hasClass = function (anyClass) { return `${this}[contains(concat(" ", normalize-space(@class), " "), " ${anyClass} ")]`; };
return xpaths('//div'.hasClass("item-summary")).map((div) => { return {
  url: xpath("./div".hasClass("post-title") + "/h3/a", div).href,
  chapter: xpath(".//span".hasClass("chapter"), div).textContent.replace(/.*第([^第]+)話.*/, "$1"), }; });

const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const xpath = (path, root) => document.evaluate(path, root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
return xpaths('//div[@class="thumb-item-flow col-6 col-md-3"][descendant::li]').map((div) => ({
  url: xpath('div[contains(concat(" ",normalize-space(@class)," ")," series-title ")]/a',div).href,
  chapter: xpath('ul[contains(@class,"at-series")]/li[1]/a',div).title.replace(/Chapter /,'')
}));

/

const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const xpath = (path, root) => document.evaluate(path, root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
return xpaths('//div[@class="col-sm-6"]').slice(-20).map((div)=>({
  url: xpath('descendant::h2/a', div).href,
  chapter: xpath('descendant::h4/a', div).textContent}));

const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const xpath = (path, root) => document.evaluate(path, root, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
return xpaths('//div[contains(concat(" ",normalize-space(@class)," "), " chapters-list ")]/a').map((a)=>({
  url: a.href.trim(),
  chapter: xpath('span', a).textContent.trim().replace(/第(.*)話/, '$1')}));
