const { verifyToken, JWT_SECRET } = require('../middleware/auth');
const jwt = require('jsonwebtoken');

function makeReq(headers = {}, body = {}, query = {}) {
  return { headers, body, query }; 
}

function makeRes() {
  return {
    statusCalled: null,
    jsonCalled: null,
    status(code) { this.statusCalled = code; return this; },
    json(obj) { this.jsonCalled = obj; }
  };
}

test('verifyToken rejects when missing token', (done) => {
  const req = makeReq();
  const res = makeRes();
  const next = () => {
    done(new Error('next should not be called when token missing'));
  };

  verifyToken(req, res, () => {});

  // async middleware will return immediately; check response
  setImmediate(() => {
    try {
      expect(res.statusCalled).toBe(401);
      expect(res.jsonCalled).toHaveProperty('message');
      done();
    } catch (e) { done(e); }
  });
});

test('verifyToken accepts valid Bearer token', (done) => {
  const payload = { id: 'abc123', email: 'a@acet.ac.in', role: 'admin' };
  const token = jwt.sign(payload, JWT_SECRET || 'dev_jwt_secret_change_in_prod', { expiresIn: '1h' });
  const req = makeReq({ authorization: `Bearer ${token}` });
  const res = makeRes();
  const next = () => {
    try {
      expect(req.user).toBeDefined();
      expect(req.user).toHaveProperty('email', payload.email);
      done();
    } catch (e) { done(e); }
  };

  verifyToken(req, res, next);
});

test('verifyToken rejects invalid token', (done) => {
  const req = makeReq({ authorization: 'Bearer invalid.token.here' });
  const res = makeRes();
  const next = () => {
    done(new Error('next should not be called with invalid token'));
  };

  verifyToken(req, res, () => {});

  setImmediate(() => {
    try {
      expect(res.statusCalled).toBe(401);
      expect(res.jsonCalled).toHaveProperty('message');
      done();
    } catch (e) { done(e); }
  });
});
