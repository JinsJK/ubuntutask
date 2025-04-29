const http = require('http');

// Burn CPU to simulate scheduling delays
function blockCPU(ms = 400) {
  const start = Date.now();
  while (Date.now() - start < ms);
}

const server = http.createServer((req, res) => {
  const start = Date.now();

  blockCPU(400); // Force delay by burning CPU

  setTimeout(() => {
    const delay = Date.now() - start;

    if (delay > 500) {
      console.error(`App stalled under load. Delay=${delay}ms. Crashing.`);
      process.exit(1);
    }

    res.writeHead(200);
    res.end("Running fine\n");
  }, 10);
});

server.listen(3000);
console.log("Crashy app running and watching for system load delays (forced crash version)");
