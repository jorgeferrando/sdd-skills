import { createServer } from 'node:http';
import { healthHandler } from './routes/health.js';

const startTime = Date.now();

const server = createServer((req, res) => {
  if (req.url === '/health') {
    healthHandler(req, res, startTime);
    return;
  }

  if (req.method === 'GET' && req.url === '/') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'not found' }));
});

server.listen(3000, () => {
  console.log('Listening on http://localhost:3000');
});
