"use strict";

window.onload = function () {
  const setup_button = document.getElementById("setup_button");
  setup_button.onclick = () => {
    setup_button.disabled = true;
    setup_popup();
  };
  setup_button.click();
};

async function setup_popup() {
  try {
    const webs = await chrome.runtime.sendNativeMessage("dev.namin.mansuki", {
      tag: "get_known_webs",
    });
    const web_selector = document.getElementById("web_selector");
    for (const web of webs) {
      web_selector.add(new Option(web, web));
    }
    await update_comic_selector(web_selector.value);
    const debug_checkbox = document.getElementById("debug_checkbox");
    const comic_selector = document.getElementById("comic_selector");
    const scan_button = document.getElementById("scan_button");
    const update_button = document.getElementById("update_button");
    const my_console = document.getElementById("console");
    const port = chrome.runtime.connect({ name: "mansuki" });
    port.onMessage.addListener(async (post_msg, _port) => {
      if (_port.name != "mansuki") {
        return;
      }
      if (post_msg.tag == "put_scanning_status") {
        if (post_msg.content) {
          debug_checkbox.disabled = true;
          scan_button.disabled = true;
          scan_button.value = "wait";
          comic_selector.disabled = true;
        } else {
          debug_checkbox.disabled = false;
          scan_button.disabled = false;
          scan_button.value = "scan";
          comic_selector.disabled = false;
          await update_comic_selector(web_selector.value);
        }
      } else if (post_msg.tag == "done_scanning") {
        port.postMessage({
          tag: "get_scanning_status",
        });
      } else if (post_msg.tag == "copy_console") {
        my_console.textContent = "";
        for (const line of post_msg.content) {
          const div = document.createElement("div");
          if (typeof line[0] === "string" || line[0] instanceof String) {
            const spans = line[0].split("%c");
            div.innerHTML =
              spans
                .map((span, i) =>
                  i == 0
                    ? span
                    : '<span style="' + line[i] + '">' + span + "</span>"
                )
                .join("") + "<br>";
            my_console.append(div);
          }
        }
      } else if (post_msg.tag == "update_console") {
        const div = document.evaluate(
          "(./div)[" + (post_msg.index + 1) + "]",
          my_console,
          null,
          XPathResult.FIRST_ORDERED_NODE_TYPE,
          null
        ).singleNodeValue;
        if (
          typeof post_msg.content[0] === "string" ||
          post_msg.content[0] instanceof String
        ) {
          const spans = post_msg.content[0].split("%c");
          div.innerHTML =
            spans
              .map((span, i) =>
                i == 0
                  ? span
                  : '<span style="' +
                    post_msg.content[i] +
                    '">' +
                    span +
                    "</span>"
              )
              .join("") + "<br>";
        }
      } else if (post_msg.tag == "append_console") {
        const div = document.createElement("div");
        if (
          typeof post_msg.content[0] === "string" ||
          post_msg.content[0] instanceof String
        ) {
          const spans = post_msg.content[0].split("%c");
          div.innerHTML =
            spans
              .map((span, i) =>
                i == 0
                  ? span
                  : '<span style="' +
                    post_msg.content[i] +
                    '">' +
                    span +
                    "</span>"
              )
              .join("") + "<br>";
          my_console.append(div);
        }
      }
    });
    scan_button.onclick = async function () {
      port.postMessage({
        tag: "start_scanning",
        debug: debug_checkbox.checked,
        url: comic_selector.value,
      });
      return false;
    };
    web_selector.onchange = async function () {
      await update_comic_selector(web_selector.value);
    };
    port.postMessage({
      tag: "get_scanning_status",
    });
    port.postMessage({
      tag: "get_console",
    });
  } catch (err) {
    alert(err);
  }
}

async function update_comic_selector(web) {
  const comics = await chrome.runtime.sendNativeMessage("dev.namin.mansuki", {
    tag: "get_known_comics",
    domain: web,
  });
  const comic_selector = document.getElementById("comic_selector");
  comic_selector.innerText = null;
  // for (const option of comic_selector.options) {
  //   comic_selector.options.remove(0);
  // }
  comic_selector.add(new Option("All new comics", "https://" + web));
  for (const comic of comics) {
    comic_selector.add(
      new Option(
        "" +
          comic.comic +
          ") " +
          comic.title.substring(0, 20) +
          (comic.title.length > 20 ? "..." : ""),
        comic.url
      )
    );
  }
}
