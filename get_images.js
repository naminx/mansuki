const xpaths = (path, root = document) => {
  const query = document.evaluate(path, root, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
  return Array(query.snapshotLength).fill(0).map((_, index) => query.snapshotItem(index)); };
String.prototype.hasClass = function (anyClass) {
  return `${this}[contains(concat(" ", normalize-space(@class), " "), " ${anyClass} ")]`; };
return xpaths("//img".hasClass("wp-manga-chapter-img")).map((img) => img.src);

/ return d=document,n=null,(m=>(a=d.evaluate(m,d,n,7,n),Array(a.snapshotLength).fill(0).map((_,t)=>a.snapshotItem(t))))('//img[contains(concat(" ",@class," ")," wp-manga-chapter-img ")]').map(a=>a.src)
