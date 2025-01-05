const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const blobURLtoDataURL = (url) => fetch(url).then((response) => response.blob()).then(
  (blob) => new Promise((resolve, reject) => { const reader = new FileReader(); reader.onloadend =
  () => resolve(reader.result); reader.onerror = reject; reader.readAsDataURL(blob); }));
const header = xpaths('//div[@id="sidemenu"]')[0];
const num_pages = xpaths('//div[@id="menu_slidercaption"]')[0].textContent.replace(/.*\//, "");
const leftArrowEvent = new KeyboardEvent("keydown", {
  key: "ArrowLeft",
  code: "ArrowLeft",
  keyCode: 37,
  which: 37,
  bubbles: true,
  cancelable: true,
});
const div_content = xpaths('//div[@id="content"]')[0];
const next = () => div_content.dispatchEvent(leftArrowEvent);
for (var n = 0; n <= num_pages; ++n) { console.log("" + n + "/" + num_pages);
  do { await sleep(100); } while ( document.evaluate(
    'count(//div[@id="content-p' + n + '"]/div/div/img)',
    document, null, XPathResult.NUMBER_TYPE, null).numberValue != 3);
  const imgs = xpaths('//div[@id="content-p' + n + '"]/div/div/img');
  await blobURLtoDataURL(imgs[0].src).then(function (dataUrl) {
    const img = document.createElement("img");
    img.style.display = "none"; img.src = dataUrl; header.append(img); });
  await blobURLtoDataURL(imgs[1].src).then(function (dataUrl) {
    const img = document.createElement("img");
    img.style.display = "none"; img.src = dataUrl; header.append(img); });
  await blobURLtoDataURL(imgs[2].src).then(function (dataUrl) {
    const img = document.createElement("img");
    img.style.display = "none"; img.src = dataUrl; header.append(img); });
}
console.log("done");
