const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  throw new Error('JWT_SECRET is required. Set it before starting the backend.');
}

const verifyToken = (req, res, next) => {
  const authHeader = req.headers.authorization || req.headers.Authorization || req.body?.token || req.query?.token;
  let token = null;
  if (authHeader && typeof authHeader === 'string') {
    if (authHeader.startsWith('Bearer ')) token = authHeader.slice(7);
    else token = authHeader;
  }

  if (!token) return res.status(401).json({ message: 'Missing auth token' });

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    req.user = payload;
    return next();
  } catch (err) {
    return res.status(401).json({ message: 'Invalid or expired token' });
  }
};

module.exports = { verifyToken, JWT_SECRET };
