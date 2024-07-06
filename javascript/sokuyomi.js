const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const pages = xpaths('//div[contains(@id,"h5v-imgcontainer-")]');
var canvas = document.createElement("canvas");
for (const [idx, page] of pages.entries()) {
  if (page.style.left != "0px") H5V.Navigation.ScrollView.scrollLeft(H5V.Navigation.UserSettings.scrollAnimation);
  do { await sleep(1000); } while (document.evaluate("count(img)", page, null, XPathResult.NUMBER_TYPE, null).numberValue == 0);
  const img = xpaths("img", page)[0];
  canvas.width = img.width;
  canvas.height = img.height;
  var ctx = canvas.getContext("2d");
  ctx.drawImage(img, 0, 0);
  img.src = canvas.toDataURL("mutelu/org");
}
console.log("done");
