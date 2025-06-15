const express = require("express");
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");
const { randomUUID } = require("crypto");
const { default: PQueue } = require("p-queue");
const multer = require("multer");

const app = express();
const port = 3000;

app.use(express.json());

const outputDir = path.join(__dirname, "outputs");
const uploadDir = path.join(__dirname, "uploads");
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);
if (!fs.existsSync(outputDir)) fs.mkdirSync(outputDir);

const upload = multer({
  dest: uploadDir,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5 MB
  },
});

// Create job queue with max concurrency
const queue = new PQueue({ concurrency: 2 }); // Adjust concurrency as needed

// Process job
const runPythonJob = (inputData) => {
  return new Promise((resolve, reject) => {
    const filename = `${Date.now()}-${randomUUID()}.json`;
    const fullPath = path.join(outputDir, filename);
    inputData.output_file = fullPath;
    const py = spawn("python", [path.join(__dirname, "scripts", "script.py")]);

    let stdout = "",
      stderr = "";

    py.stdin.write(JSON.stringify(inputData));
    py.stdin.end();

    py.stdout.on("data", (data) => (stdout += data.toString()));
    py.stderr.on("data", (data) => (stderr += data.toString()));

    py.on("close", (code) => {
      if (code !== 0 || !stdout.includes("DONE")) {
        return reject(`Python error: ${stderr}`);
      }

      if (!fs.existsSync(fullPath)) {
        return reject("Output file not found");
      }

      try {
        const fileData = fs.readFileSync(fullPath, "utf8");
        fs.unlink(
          fullPath,
          (err) => err && console.error("Cleanup failed:", err)
        );
        resolve(JSON.parse(fileData));
      } catch (err) {
        reject("Error reading output file");
      }
    });
  });
};

app.post("/process", upload.single("file"), async (req, res) => {
  const inputData = req.body;
  const file_path = req.file ? path.join(__dirname, req.file.path) : null;
  try {
    const result = await queue.add(() => runPythonJob(inputData));
    res.json({ status: "completed", result });
  } catch (err) {
    res.status(500).json({ error: err.toString() });
  }
});

app.listen(port, () => {
  console.log(`🚀 Server running at http://localhost:${port}`);
});
