const xpaths = (path, root = document) => { const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
const isTainted = async (ctx) => { try { await ctx.toDataURL(); return true; } catch (err) { return err.code === 18; } };
const leftArrowEvent = new KeyboardEvent("keydown", {
  key: "ArrowLeft",
  code: "ArrowLeft",
  keyCode: 37,
  which: 37,
  bubbles: true,
  cancelable: true,
});
const renderer = xpaths('//div[@id="renderer"]')[0];
const next = () => renderer.dispatchEvent(leftArrowEvent);

const root = xpaths('//div[@id="root"]')[0];
const total = 1 * xpaths('//div[@id="pageSliderCounter"]')[0].textContent.replace( /[0-9]+\//, "");

var current = 1 * xpaths('//div[@id="pageSliderCounter"]')[0].textContent.replace( /\/[0-9]+/, "");
var canvas = xpaths('//div[(@id="viewport0" or @id="viewport1") and @style[contains(., "z-index: 0")]]/canvas')[0];
console.log("" + current + "/" + total);
var img = document.createElement("img");
img.style.display = "none";
img.src = canvas.toDataURL("mutelu/org");
root.append(img);
do {
  next();
  do { await sleep(1000); } while (window.getComputedStyle(canvas.parentElement).getPropertyValue("z-index") == "0");
  current = 1 * xpaths('//div[@id="pageSliderCounter"]')[0].textContent.replace( /\/[0-9]+/, "");
  canvas = xpaths('//div[(@id="viewport0" or @id="viewport1") and @style[contains(., "z-index: 0")]]/canvas')[0];
  do { await sleep(1000); } while (!(await isTainted(canvas)));
  console.log("" + current + "/" + total);
  img = document.createElement("img");
  img.style.display = "none";
  img.src = canvas.toDataURL("mutelu/org");
  root.append(img);
} while (current < total);
