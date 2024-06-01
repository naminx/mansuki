const page = arguments[0];
return "list.html?page=" + page;

const page = arguments[0]
if ("" + page == "1") return "";
const xpaths = (path) => {
  const query = document.evaluate(path, document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const anker = xpaths('//a[contains(@class, "go-load-more")]')[0];
while (xpaths('//div[@class="col-sm-6"]').length < 20 * page) {
  anker.click();
  while (anker.classList.contains('onWaiting')) { sleep(1000); }
}
return "#";

/
