const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null,);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const next = xpaths('//button[@class="pswp__button--arrow--left"]')[0];
const body = xpaths('//body')[0];
const header = document.createElement("div");
header.style.display = "none";
header.style.visibility = "hidden";
body.append(header);
const num_pages = 1 * xpaths(
  '//div[contains(@class,"ProgressBar__ProgressBarText")]',
)[0].textContent.replace(/[0-9]+\/([0-9]+) .*%/, "$1");
var cur_page = 1;
var slider_page = 1 * xpaths(
  '//div[contains(@class,"ProgressBar__ProgressBarText")]',
)[0].textContent.replace(/([0-9]+)\/[0-9]+ .*%/, "$1");
while (slider_page <= num_pages) {
  const base_page = 1 * (slider_page % 2 == 0 ? slider_page : slider_page == 1 ? 0 : slider_page - 1);
  const item = xpaths('//div[@class="pswp__item"]').filter((div) => -1 * div.style.transform.replace(
    /translate3d\(([^,]+)px,[^,]+,[^,]+\)/, "$1",) == (base_page / 2) * 1392,)[0];
  const canvases = xpaths("div/div/canvas", item);
  var canvas = null;
  var img = null;
  if (cur_page == base_page) {
    console.log("" + cur_page + "/" + num_pages);
    canvas = canvases[1];
    img = document.createElement("img");
    img.src = canvas.toDataURL("mutelu/org");
    header.append(img);
    ++cur_page;
  }
  if (cur_page == base_page + 1) {
    console.log("" + cur_page + "/" + num_pages);
    canvas = canvases[0];
    img = document.createElement("img");
    img.src = canvas.toDataURL("mutelu/org");
    header.append(img);
    ++cur_page;
  }
  next.click();
  await sleep(1000);
  if (slider_page == num_pages)
    break;
  slider_page = 1 * xpaths(
    '//div[contains(@class,"ProgressBar__ProgressBarText")]',
  )[0].textContent.replace(/([0-9]+)\/[0-9]+ .*%/, "$1");
}
console.log("done");
