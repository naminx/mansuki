"use strict";

var debug = false;

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
      debug = post_msg.debug;
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

const max_pages = 50;
const max_num_tries = 3;
var runtime_error = false;
var scanning = false;
var port = null;
var current_domain = null;

const manga1001s = [
  "mangaraw.so",
  "mangaraw.io",
  "manga1001.se",
  "rawotaku.net",
];

async function default_delay(extra = 0) {
  const sleep = (msec) =>
    new Promise((resolve) => setTimeout(() => resolve(), msec));
  await sleep(3000 + extra + Math.random() * 3000);
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
  log_ok("override", override);
  runtime_error = false;
  const web = await query_host("get_web_info", {
    url: "https://" + domain + "/",
  });
  log_ok("web_info", web);

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
  log_ok("response", response);
  my_console.log("yeah");
  return;
*/

  var next_last_visit = web.lastVisit;
  var hit = false;
  const tab = await createTab("https://www.google.com/ncr");
  console.log("1");
  for (const ipage of [...Array(!override ? max_pages : 1).keys()]) {
    // if (ipage <= 10) continue;
    const page = ipage + 1;
    console.log("2:" + page);
    const get_nth_page = await run_code(tab.id, exec_script, [
      web.getNthPage,
      page,
    ]);
    log_ok("nth_page", get_nth_page);
    const nth_page_path = get_nth_page[0].result;
    my_console.log("%cfetching page " + page, "color: gray");
    if (nth_page_path != "#") {
      await navigateTab(tab.id, "https://" + web.domain + nth_page_path);
      if (page == 1 && current_domain == "rawinu.com")
        await default_delay(7000);
    }
    if (false && manga1001s.includes(current_domain)) {
      await run_code(tab.id, exec_script, [
        "" +
          " const sleep = (msec) => new Promise((resolve) => " +
          "   setTimeout(() => resolve(), msec));" +
          " do { await sleep(1000); } " +
          "   while (document.evaluate('" +
          '     count(//div[contains(concat(" ", normalize-space(@class), " "), " iv-card ")]' +
          '            /img[contains(concat(" ", normalize-space(@class), " "), " lazyloaded ")])' +
          "',   document, null, XPathResult.NUMBER_TYPE, null).numberValue > 0);",
      ]);
    }
    await default_delay();
    const scrape_comics = await run_code(tab.id, exec_script, [web.getComics]);
    log_ok("get_comics", scrape_comics);
    const new_comics = !override ? scrape_comics[0].result : override;
    const urls = takeWhile(
      (comic_url) =>
        !(hit ||=
          comic_url
            .replace(/%([0-9A-Fa-f][0-9A-Fa-f])/g, (hex) => hex.toLowerCase())
            .replace("!", "%21") == web.lastVisit),
      new_comics.map((comic) => comic.url)
    );
    log_ok("urls", urls);
    if (page == 1) {
      if (urls.length == 0) {
        my_console.log("%cdone: (no update)", "color: gray");
        break;
      }
      next_last_visit = urls[0];
    }
    const comics = await query_host("get_comic_infos", { urls: urls });
    log_ok("comic_info", comics);
    // my_console.log(new_comics);
    // my_console.log(comics);
    for (const comic of comics) {
      log_ok("comic", comic);
      print_comic(comic);
      comic.new_chap = new_comics.find(
        (new_comic) =>
          new_comic.url
            .replace(/%([0-9A-Fa-f][0-9A-Fa-f])/g, (hex) => hex.toLowerCase())
            .replace("!", "%21") == comic.url
      ).chapter;
      if (!!comic.new_chap && !is_newer_than(comic.new_chap, comic.chapter))
        continue;
      const comic_tab = await createTab(comic.url);
      await default_delay();
      const scrape_chapters = await run_code(comic_tab.id, exec_script, [
        web.getChapters,
      ]);
      log_ok("get_chapters", scrape_chapters);
      // chapters is mutable!
      var chapters = scrape_chapters[0].result.filter((chap) =>
        is_newer_than(chap.chapter, comic.chapter)
      );
      log_ok("chapters (filtered)", chapters);

      // chapters may be altered by this block of codes
      if (
        chapters.length == 0 ||
        chapters[chapters.length - 1].chapter != comic.new_chap
      ) {
        const scrape_latest_chap = await run_code(comic_tab.id, exec_script, [
          web.getLatestChap,
        ]);
        log_ok("get_latest_chap", scrape_latest_chap);
        const latest_chap = scrape_latest_chap[0].result;
        if (
          chapters.length == 0 ||
          chapters[chapters.length - 1].chapter != latest_chap.chapter
        ) {
          chapters.push({ chapter: latest_chap.chapter, url: latest_chap.url });
        }
      }
      log_ok("chapters (final)", chapters);

      for (const chapter of chapters) {
        const chap_splitted = chapter.chapter.split(".", 2);
        const folder =
          comic.folder +
          ("00" + chap_splitted[0]).slice(-3) +
          (chap_splitted.length == 1 ? "" : "." + chap_splitted[1]) +
          "/";
        const chapter_tab = comic_tab;
        await navigateTab(chapter_tab.id, chapter.url);

        /* if (
          current_domain == "rawinu.com" ||
          current_domain == "nicomanga.com"
        ) {
          await run_code(tab.id, exec_script, [
            ` const sleep = (msec) => new Promise((resolve) => setTimeout(() => resolve(), msec));
              do {
                await sleep(1000);
                alert(document.evaluate('count(//img[contains(concat(" ", normalize-space(@class), " "), " chapter-img " )])', document, null, XPathResult.NUMBER_TYPE, null).numberValue);
              } while (
                document.evaluate
                  ( 'count(//img[contains(concat(" ", normalize-space(@class), " "), " chapter-img " )])',
                    document, null, XPathResult.NUMBER_TYPE, null
                  ).numberValue <= 1
              );`,
          ]);
        } */

        await default_delay();
        const scrape_images = await run_code(chapter_tab.id, exec_script, [
          web.getImages,
        ]);
        log_ok("images", scrape_images);
        const image_urls = scrape_images[0].result;
        var chapter_ok = image_urls.length > 0;
        my_console.log("%cchapter " + chapter.chapter + " [", "color: gray");
        // if (!manga1001s.includes(current_domain) || chapter_ok) {
        for (const [img_idx, image_url] of image_urls.entries()) {
          if (img_idx == 0) {
            await updateDynamicRules(chapter.url, image_url);
          }
          const args = [chapter_tab.id, image_url, folder, img_idx + 1];
          var image_ok = false;
          for (var tries = 1; !image_ok && tries <= max_num_tries; ++tries) {
            image_ok = image_ok || (await download_image(tries, ...args));
          }
          chapter_ok = image_ok && chapter_ok;
        }
        /*
        } else {
          const num_images = await run_code(chapter_tab.id, exec_script, [
            "return document.evaluate(arguments[0], document, null, " +
              "XPathResult.NUMBER_TYPE, null).numberValue;",
            'count(//div[contains(concat(" ", normalize-space(@class), " "), ' +
              '" chapter-lazy ")])',
          ]);
          chapter_ok = num_images[0].result > 0;
          for (var n = 1; n <= num_images[0].result; ++n) {
            const data_url = await run_code(chapter_tab.id, exec_async_script, [
              "   const div = document.evaluate(" +
                '   arguments[0] + "[" + arguments[1] + "]", document, null,' +
                "   XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;" +
                " div.scrollIntoView();" +
                " const sleep = (msec) => new Promise((resolve) => " +
                "   setTimeout(() => resolve(), msec));" +
                " do { await sleep(1000); } " +
                "   while (document.evaluate('count(canvas)', div, null, " +
                "     XPathResult.NUMBER_TYPE, null).numberValue == 0);" +
                " const isTainted = (ctx) => { try { var dummy = " +
                "   ctx.toDataURL(); return false; } " +
                "   catch(err) { return (err.code === 18); } };" +
                " const canvas = document.evaluate('canvas', div, null, " +
                "   XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;" +
                " do { await sleep(1000); } " +
                "   while (!isTainted(canvas));" +
                " await sleep(1000);" +
                ' return canvas.toDataURL("manga/raw");',
              '(//div[contains(concat(" ", normalize-space(@class), " "), ' +
                '" chapter-lazy ")])',
              n,
            ]);
            await save_data_url(data_url[0].result, folder, n);
          }
        }
        */
        my_console.log_("%c]", "color: gray");
        if (chapter_ok) {
          const update_chapter = await query_host("update_chapter", {
            comic: comic.comic,
            chapter: chapter.chapter,
          });
          log_ok("update_chapter", update_chapter);
        }
        await navigateTab(chapter_tab.id, comic.url);
      }
      if (override) {
        my_console.log("%cdone", "color: gray");
      }
      chrome.tabs.remove(comic_tab.id);
    }
    if (hit == true) {
      if (!runtime_error) {
        const update_last_visit = await query_host("update_last_visit", {
          domain: web.domain,
          url: next_last_visit,
        });
        log_ok("update_last_visit", update_last_visit);
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
        log_ok("update_last_visit", update_last_visit);
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

async function download_image(num_tries, tab_id, url, folder, num) {
  return await fetch(url, {
    method: "GET",
    headers: {
      Accept: "image/webp;q=1,image/jpeg;q=0.9,image/*;q=0.8",
    },
  })
    .then(async (response) => {
      log_ok("response", response);
      return response.ok
        ? response.blob()
        : Promise.reject(
            "Bad server response: " + response.status + " (" + num_tries + ")"
          );
    })
    .then(
      async (blob) =>
        await new Promise((resolve, reject) => {
          // log_ok("blob", blob);
          const reader = new FileReader();
          reader.onloadend = () => resolve(reader.result);
          reader.onerror = () => reject("Error reading blob");
          reader.readAsDataURL(blob);
        })
    )
    .then(async (base64) => {
      // log_ok("base64", base64);
      const num_padded = ("00" + num).slice(-3);
      const filename = folder + num_padded;
      log_ok("filename", filename);
      // log_ok("filename & contents", { file: filename, uri: base64 });
      return await query_host("save_image", {
        file: filename,
        uri: base64,
      });
    })
    .then((save_image) => {
      // log_ok("save_image", save_image);
      const color = num_tries == 1 ? "green" : "orange";
      if (num % 10 == 0) my_console.log_("%c" + num, "color: " + color);
      else if (num % 5 == 0) my_console.log_("%c|", "color: " + color);
      else my_console.log_("%c·", "color: " + color);
      return true;
    })
    .catch(async (error) => {
      await default_delay();
      if (num_tries == max_num_tries) {
        my_console.log_("%cx", "color: red");
        runtime_error = true;
      }
      const forward = my_console.log("%c" + error, "color: red");
      my_console.back(forward);
      return false;
    });
}

async function save_data_url(data_url, folder, num) {
  const num_padded = ("00" + num).slice(-3);
  const filename = folder + num_padded;
  log_ok("filename", filename);
  // log_ok("filename & contents", { file: filename, uri: base64 });
  await query_host("save_image", {
    file: filename,
    uri: data_url,
  });
  const color = "green";
  if (num % 10 == 0) my_console.log_("%c" + num, "color: " + color);
  else if (num % 5 == 0) my_console.log_("%c|", "color: " + color);
  else my_console.log_("%c·", "color: " + color);
  return true;
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

function log_ok(label, result) {
  if (!chrome.runtime.lastError) {
    if (debug == true) {
      my_console.log("%c" + label, "color: orange");
      my_console.log(result);
    }
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
  // if (1 * xs[1] > 1 * ys[1]) return true;
  // if (1 * xs[1] < 1 * ys[1]) return false;
  if (xs[1] > ys[1]) return true;
  if (xs[1] < ys[1]) return false;
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

async function exec_async_script(script, ...argv) {
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
    "(async (me) => {" +
      "const result = await (async (...arguments) => " +
      ("   {" + script + "})(" + args + ");") +
      "me.dispatchEvent(" +
      (" new CustomEvent(" + JSON.stringify(uuid) + ",") +
      "    { detail: { value: JSON.stringify(result) }}));" +
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
