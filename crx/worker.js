"use strict";

const debug = false;

// chrome.runtime.onMessage.addListener(handleMessages);

// This handle function must return `true` to indicate that we want to send
// a response asynchronously.
// In order to return `true`, it cannot be declared `async`, or else it will
// return a promise.
/*
function handleMessages(msg, _sender, respond) {
  // Return early if this msg isn't meant for the offscreen document.
  if (msg.target !== "worker") {
    respond();
  } else if (msg.tag == "get_scanning_status") {
    respond(scanning);
  } else if (msg.tag == "start_scanning") {
    scanweb(msg.domain);
  }
  return true;
}
*/

// [ { url: "https://hotelmanga.com/manga-slow-life-in-the-world-of-eroge.html", chapter: "5", }, ]

chrome.runtime.onConnect.addListener((new_port) => {
  if (new_port.name != "mansuki") {
    return;
  }
  port = new_port;
  port.onDisconnect.addListener((_disconnected_port) => {
    port = null;
  });
  port.onMessage.addListener((post_msg, _port) => {
    if (_port.name != "mansuki") {
      return;
    }
    if (post_msg.tag == "get_scanning_status") {
      if (port !== null) {
        port.postMessage({
          tag: "put_scanning_status",
          content: scanning,
        });
      }
    } else if (post_msg.tag == "start_scanning") {
      const url = new URL(post_msg.url);
      current_domain = url.hostname;
      var args =
        url.pathname == "/"
          ? [current_domain]
          : [current_domain, [{ url: post_msg.url, chapter: "999" }]];
      scanweb(...args).then(() => {
        scanning = false;
        if (port !== null) {
          port.postMessage({
            tag: "done_scanning",
          });
        }
      });
    } else if (post_msg.tag == "get_console") {
      if (port !== null) {
        port.postMessage({
          tag: "copy_console",
          content: my_console.lines,
        });
      }
    }
  });
});

const OFFSCREEN_DOCUMENT_PATH = "/offscreen.htm";

async function closeOffscreenDocument() {
  if (!(await hasOffscreenDocument())) {
    return;
  }
  await chrome.offscreen.closeDocument();
}

async function hasOffscreenDocument() {
  // Check all windows controlled by the service worker if one of them is the
  //   offscreen document.
  const matchedClients = await clients.matchAll();
  for (const client of matchedClients) {
    if (client.url.endsWith(OFFSCREEN_DOCUMENT_PATH)) {
      return true;
    }
  }
  return false;
}

const max_pages = 25;
var runtime_error = false;
var scanning = false;
var port = null;
var current_domain = null;

const manga1001s = ["mangaraw.so", "mangaraw.io", "manga1001.se"];

async function default_delay() {
  const sleep = (msec) =>
    new Promise((resolve) => setTimeout(() => resolve(), msec));
  if (manga1001s.includes(current_domain)) {
    await sleep(5000 + Math.random() * 5000);
  } else {
    await sleep(1000);
  }
}

function createTab(url) {
  return new Promise((resolve) => {
    chrome.tabs.create({ url }).then(async (tab) => {
      chrome.tabs.onUpdated.addListener(async function listener(tabId, info) {
        if (info.status === "complete" && tabId === tab.id) {
          chrome.tabs.onUpdated.removeListener(listener);
          await default_delay();
          resolve(tab);
        }
      });
    });
  });
}

function navigateTab(tab_id, url) {
  return new Promise((resolve) => {
    chrome.tabs.onUpdated.addListener(async function listener(tabId, info) {
      if (info.status === "complete" && tabId === tab_id) {
        chrome.tabs.onUpdated.removeListener(listener);
        await default_delay();
        resolve();
      }
    });
    chrome.tabs.update(tab_id, { url });
  });
}

// Fired when an action icon is clicked.
// Callback parameter type is `tabs.Tab`.
// This must be defined after `main`.
// chrome.action.onClicked.addListener(scanweb);

async function scanweb(domain, override = undefined) {
  if (scanning === true) {
    return;
  }
  scanning = true;
  my_console.clear();
  runtime_error = false;
  const web = await query_host("get_web_info", {
    url: "https://" + domain + "/",
  });
  log_ok(web);

  /*
  const html = await run_code(tab.id, () => document.documentElement.outerHTML);
  if (!(await hasOffscreenDocument())) {
    await chrome.offscreen.createDocument({
      url: OFFSCREEN_DOCUMENT_PATH,
      reasons: [chrome.offscreen.Reason.IFRAME_SCRIPTING],
      justification: "Parse DOM",
    });
  }

  var response = await chrome.runtime.sendMessage({
    target: "offscreen",
    html: html[0].result,
    script: web.getNthPage,
    argv: [1],
  });
  log_ok(response);
  my_console.log("yeah");
  return;
*/

  var next_last_visit = web.lastVisit;
  var hit = false;
  const tab = await createTab("https://www.google.com/ncr");
  for (const ipage of [...Array(!override ? max_pages : 1).keys()]) {
    const page = ipage + 1;
    const get_nth_page = await run_code(tab.id, exec_script, [
      web.getNthPage,
      page,
    ]);
    log_ok(get_nth_page);
    const nth_page_path = get_nth_page[0].result;
    my_console.log("%cfetching page " + page, "color: gray");
    await navigateTab(tab.id, "https://" + web.domain + nth_page_path);
    const scrape_comics = await run_code(tab.id, exec_script, [web.getComics]);
    log_ok(scrape_comics);
    const new_comics = !override ? scrape_comics[0].result : override;
    const urls = takeWhile(
      (comic_url) => !(hit ||= comic_url == web.lastVisit),
      new_comics.map((comic) => comic.url)
    );
    if (page == 1) {
      if (urls.length == 0) {
        my_console.log("%cdone: (no update)", "color: gray");
        break;
      }
      next_last_visit = urls[0];
    }
    const comics = await query_host("get_comic_infos", { urls: urls });
    log_ok(comics);
    for (const comic of comics) {
      log_ok(comic);
      print_comic(comic);
      comic.new_chap = new_comics.find(
        (new_comic) => new_comic.url == comic.url
      ).chapter;
      if (!!comic.new_chap && !is_newer_than(comic.new_chap, comic.chapter))
        continue;
      const comic_tab = await createTab(comic.url);
      const scrape_chapters = await run_code(comic_tab.id, exec_script, [
        web.getChapters,
      ]);
      log_ok(scrape_chapters);
      const chapters = scrape_chapters[0].result.filter((chap) =>
        is_newer_than(chap.chapter, comic.chapter)
      );
      for (const chapter of chapters) {
        const chap_splitted = chapter.chapter.split(".", 2);
        const folder =
          comic.folder +
          ("00" + chap_splitted[0]).slice(-3) +
          (chap_splitted.length == 1 ? "" : "." + chap_splitted[1]) +
          "/";
        const chapter_tab = comic_tab;
        await navigateTab(chapter_tab.id, chapter.url);
        if (current_domain == "nicomanga.com") {
          await run_code(chapter_tab.id, exec_script, [
            "document.evaluate(arguments[0], document, null, 9, null).singleNodeValue.click();return true;",
            '//button[contains(concat(" ",normalize-space(@class)," ")," readmore ")]',
          ]);
          await default_delay();
        }
        const scrape_images = await run_code(chapter_tab.id, exec_script, [
          web.getImages,
        ]);
        log_ok(scrape_images);
        const image_urls = scrape_images[0].result;
        var chapter_ok = true;
        my_console.log("%cchapter " + chapter.chapter + " [", "color: gray");
        for (const [img_idx, image_url] of image_urls.entries()) {
          if (img_idx == 0) {
            updateDynamicRules(chapter.url, image_url);
          }
          const args = [chapter_tab.id, image_url, folder, img_idx + 1];
          chapter_ok = (await download_image(...args)) && chapter_ok;
        }
        my_console.log_("%c]", "color: gray");
        if (chapter_ok) {
          const update_chapter = await query_host("update_chapter", {
            comic: comic.comic,
            chapter: chapter.chapter,
          });
          log_ok(update_chapter);
        }
        await navigateTab(chapter_tab.id, comic.url);
      }
      chrome.tabs.remove(comic_tab.id);
    }
    if (hit == true) {
      if (!runtime_error) {
        const update_last_visit = await query_host("update_last_visit", {
          domain: web.domain,
          url: next_last_visit,
        });
        log_ok(update_last_visit);
        my_console.log("%cdone: (last visit)", "color: gray");
      }
      break;
    }
    if (page == max_pages) {
      if (!runtime_error) {
        const update_last_visit = await query_host("update_last_visit", {
          domain: web.domain,
          url: next_last_visit,
        });
        log_ok(update_last_visit);
        my_console.log("%cdone: (max pages)", "color: gray");
      }
    }
  }
}

function progress(comic) {
  return "(Vol." + comic.volume + ", Ch." + comic.chapter + ")";
}

function print_comic(comic) {
  my_console.log(
    "%c" + comic.title + " %c" + progress(comic),
    "color: yellow",
    "color: gray"
  );
}

async function updateDynamicRules(chapter_url, image_url) {
  const rules = [
    {
      id: 1,
      action: {
        type: "modifyHeaders",
        requestHeaders: [
          {
            header: "Referer",
            operation: "set",
            value: new URL(chapter_url).origin + "/",
          },
        ],
      },
      condition: {
        domains: [chrome.runtime.id],
        urlFilter: "|" + new URL(image_url).origin + "/",
        resourceTypes: ["xmlhttprequest"],
      },
    },
  ];
  await chrome.declarativeNetRequest.updateDynamicRules({
    removeRuleIds: rules.map((r) => r.id),
    addRules: rules,
  });
}

async function download_image(tab_id, url, folder, num, tries = 1) {
  return await fetch(url, {
    method: "GET",
    headers: {
      Accept: "image/webp;q=1,image/jpeg;q=0.9,image/*;q=0.8",
    },
  })
    .then(async (response) => {
      const sleep = (msec) =>
        new Promise((resolve) => setTimeout(() => resolve(), msec));
      log_ok(response);
      return response.ok
        ? response.blob()
        : tries < 3
        ? (await default_delay(),
          download_image(tab_id, url, folder, num, tries + 1))
        : Promise.reject("Bad server response: " + response.status);
    })
    .then(
      async (blob) =>
        await new Promise((resolve, reject) => {
          log_ok(blob);
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = () => reject("Error reading blob");
          reader.readAsDataURL(blob);
        })
    )
    .then(async (base64) => {
      log_ok(base64);
      const num_padded = ("00" + num).slice(-3);
      const filename = folder + num_padded;
      log_ok({ file: filename, uri: base64 });
      return await query_host("save_image", {
        file: filename,
        uri: base64,
      });
    })
    .then((save_image) => {
      log_ok(save_image);
      if (num % 10 == 0) my_console.log_("%c" + num, "color: green");
      else if (num % 5 == 0) my_console.log_("%c|", "color: green");
      else my_console.log_("%c·", "color: green");
      return true;
    })
    .catch((error) => {
      my_console.log_("%cx", "color: red");
      runtime_error = true;
      const forward = my_console.log("%c" + error, "color: red");
      my_console.back(forward);
      return false;
    });
}

var my_console = {
  lines: [],
  currentLine: 0,
  log: (...msgs) => {
    const current_line = my_console.currentLine;
    while (my_console.lines[my_console.currentLine]) {
      my_console.currentLine++;
    }
    my_console.log_(...msgs);
    return my_console.currentLine - current_line;
  },
  log_: (msg, ...msgs) => {
    if (
      my_console.lines[my_console.currentLine] &&
      my_console.lines[my_console.currentLine][0]
    ) {
      my_console.lines[my_console.currentLine][0] += msg;
      my_console.lines[my_console.currentLine] = [
        ...my_console.lines[my_console.currentLine],
        ...msgs,
      ];
      if (port !== null) {
        port.postMessage({
          tag: "update_console",
          index: my_console.currentLine,
          content: my_console.lines[my_console.currentLine],
        });
      }
    } else {
      my_console.lines[my_console.currentLine] = [msg, ...msgs];
      if (port !== null) {
        port.postMessage({
          tag: "append_console",
          index: my_console.currentLine,
          content: my_console.lines[my_console.currentLine],
        });
      }
    }
    console.clear();
    my_console.lines.forEach((line) => console.log(...line));
  },
  back: (n) => {
    my_console.currentLine -= n;
  },
  clear: () => {
    console.clear();
    my_console.lines = [];
    my_console.currentLine = 0;
    if (port !== null) {
      port.postMessage({
        tag: "copy_console",
        content: my_console.lines,
      });
    }
  },
};

function takeWhile(f, xs) {
  const takeWhileNotEmpty = (f, [x, ...xs]) =>
    f(x) ? [x, ...takeWhile(f, xs)] : [];
  return xs.length ? takeWhileNotEmpty(f, xs) : [];
}

async function current_url() {
  const tabs = await chrome.tabs.query({ currentWindow: true, active: true });
  return tabs.length > 0 ? tabs[0].url : null;
}

async function query_host(tag, param) {
  param.tag = tag;
  return await chrome.runtime.sendNativeMessage("dev.namin.mansuki", param);
}

function popup(tab_id, msg) {
  return run_code(tab_id, (m) => alert(m), [msg]);
}

function run_code(tab_id, func, args = null) {
  return chrome.scripting.executeScript(
    args === undefined || args === null || args === []
      ? { target: { tabId: tab_id }, func: func }
      : { target: { tabId: tab_id }, func: func, args: args }
  );
}

function log_ok(result) {
  if (!chrome.runtime.lastError) {
    if (debug == true) my_console.log(result);
    return true;
  } else {
    runtime_error = true;
    my_console.log("%c" + chrome.runtime.lastError, "color: red");
    return false;
  }
}

function is_newer_than(x, y) {
  const xs = x.split(".", 2);
  const ys = y.split(".", 2);
  if (1 * xs[0] > 1 * ys[0]) return true;
  if (1 * xs[0] < 1 * ys[0]) return false;
  if (xs.length > ys.length) return true;
  if (xs.length < ys.length) return false;
  if (1 * xs[1] > 1 * ys[1]) return true;
  if (1 * xs[1] < 1 * ys[1]) return false;
  return false;
}

function create_tab(url) {
  return chrome.tabs.create({ url: url });
}

function close_tab(tab_id) {
  return run_code(tab_id, () => window.close());
}

async function exec_script(script, ...argv) {
  const uid = () => {
    const tmp = performance.now().toString(36).replace(/\./g, "");
    return document.getElementById(tmp) == undefined ? tmp : uid();
  };
  const uuid = uid();
  const input = document.createElement("input");
  input.id = uuid;
  input.type = "hidden";
  document.querySelectorAll("html")[0].append(input);
  const args = argv.map(JSON.stringify).join(",");
  input.setAttribute(
    "onclick",
    "((me) => {" +
      "me.dispatchEvent(" +
      (" new CustomEvent(" + JSON.stringify(uuid) + ",") +
      "    { detail: { value: JSON.stringify" +
      ("       (((...arguments) => {" + script + "})(" + args + "))}}") +
      "));" +
      "return false;" +
      "})(this)"
  );
  result = JSON.parse(
    await new Promise((resolve) => {
      input.addEventListener(uuid, (e) => {
        resolve(e.detail.value);
      });
      input.click();
    })
  );
  input.parentNode.removeChild(input);
  return result;
}
