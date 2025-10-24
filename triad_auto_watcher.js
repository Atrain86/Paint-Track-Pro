import fs from "fs";
import { exec } from "child_process";

const WATCH_DIRS = ["triad_whiteboard", "triad_reports"];
const LOG_FILE = "triad_logs/auto_watcher.log";

function log(msg) {
  const stamp = new Date().toISOString();
  fs.appendFileSync(LOG_FILE, `[${stamp}] ${msg}\n`);
}

WATCH_DIRS.forEach(dir => {
  fs.watch(dir, { recursive: true }, (event, filename) => {
    if (!filename) return;
    log(`Detected ${event} on ${filename}`);
    exec(
      `git add . && git commit -m "Auto-watch: ${event} ${filename}" && git push origin main`,
      (err, stdout, stderr) => {
        if (err) log(`❌ ${err.message}`);
        else log(`✅ Commit successful: ${stdout}`);
      }
    );
  });
});

log("🔭 Triad Auto-Watcher active...");
