// Registering this listener when the script is first executed ensures that the
// offscreen document will be able to receive msgs when the promise returned
// by `offscreen.createDocument()` resolves.
chrome.runtime.onMessage.addListener(handleMessages);

// This handle function must return `true` to indicate that we want to send
// a response asynchronously.
// In order to return `true`, it cannot be declared `async`, or else it will
// return a promise.
function handleMessages(msg, _sender, respond) {
  // Return early if this msg isn't meant for the offscreen document.
  if (msg.target !== "offscreen") {
    return false;
  }
  exec_script(msg.html, msg.script, msg.argv).then((result) => respond(result));
  return true;
}

async function exec_script(html, script, argv) {
  // const parser = new DOMParser();
  const iframe = document.getElementsByTagName("iframe")[0];
  const args = argv.map(JSON.stringify).join(",");
  const result = await new Promise((resolve) => {
    window.addEventListener("message", async (event) => resolve(event.data));
    iframe.contentWindow.postMessage(
      "((...arguments) => {" + script + "})(" + args + ")",
      "*"
    );
  });
  return result;
}
