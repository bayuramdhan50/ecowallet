const jwt = require('jsonwebtoken');

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
        return res.status(401).json({
            success: false,
            message: 'Access token required'
        });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({
                success: false,
                message: 'Invalid or expired token'
            });
        }

        req.user = user; // Attach user info to request
        next();
    });
};

// Middleware to check if user is admin
const requireAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({
            success: false,
            message: 'Admin access required'
        });
    }
    next();
};

// Middleware to check if user is active
const requireActive = (req, res, next) => {
    if (!req.user.is_active) {
        return res.status(403).json({
            success: false,
            message: 'Account is pending admin approval'
        });
    }
    next();
};

module.exports = {
    authenticateToken,
    requireAdmin,
    requireActive
};
