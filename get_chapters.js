const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
String.prototype.hasClass = function (anyClass) {
  return `${this}[contains(concat(" ", normalize-space(@class), " "), " ${anyClass} ")]`; };
return xpaths("//li".hasClass("wp-manga-chapter") + "/a").map((a) => {
  return { url: a.href, chapter: a.textContent.replace(/.*第([^第]+)話.*/, "$1"), }; });

/ return d=document,n=null,((t,a=d)=>{const e=d.evaluate(t,a,n,7,n);return Array(e.snapshotLength).fill(0).map((t,n)=>e.snapshotItem(n))})('//li[contains(concat(" ",@class," ")," wp-manga-chapter ")]/a').map(t=>({url:t.href,chapter:t.textContent.replace(/.*第([^第]+)話.*/,"$1")}))
