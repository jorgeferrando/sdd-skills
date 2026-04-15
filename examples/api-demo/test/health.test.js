import { describe, it } from 'node:test';
import assert from 'node:assert';
import { healthHandler } from '../src/routes/health.js';

function mockReq(method) {
  return { method };
}

function mockRes() {
  const res = {
    statusCode: null,
    headers: {},
    body: null,
    writeHead(code, headers) {
      res.statusCode = code;
      res.headers = headers;
    },
    end(data) {
      res.body = JSON.parse(data);
    },
  };
  return res;
}

describe('GET /health', () => {
  it('returns 200 with healthy status and uptime', () => {
    const req = mockReq('GET');
    const res = mockRes();
    const startTime = Date.now() - 5000; // 5 seconds ago

    healthHandler(req, res, startTime);

    assert.strictEqual(res.statusCode, 200);
    assert.strictEqual(res.body.status, 'healthy');
    assert.strictEqual(typeof res.body.uptime, 'number');
    assert.ok(res.body.uptime >= 4); // at least 4 seconds
  });

  it('returns 405 for non-GET methods', () => {
    const req = mockReq('POST');
    const res = mockRes();

    healthHandler(req, res, Date.now());

    assert.strictEqual(res.statusCode, 405);
    assert.strictEqual(res.body.error, 'method not allowed');
  });
});
