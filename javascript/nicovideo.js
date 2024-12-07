const canvases = xpaths('//canvas[not(contains(@class, "canvas")) and not(contains(@class, "balloon"))]');
const header = xpaths('');
for (const canvas of canvases) {
    const img = document.createElement("img");
    img.style.display = "none";
    img.src = canvas.toDataURL("mutelu/org");
    temp1.append(img);
}
