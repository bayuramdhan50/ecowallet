const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Get all pending users (Admin only)
router.get('/pending', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, role, is_active, balance, created_at FROM users WHERE is_active = 0 AND role = "client" ORDER BY created_at DESC'
        );

        res.json({
            success: true,
            data: users
        });

    } catch (error) {
        console.error('Get pending users error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Approve user (Admin only)
router.put('/:id/approve', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { id } = req.params;

        // Update user status to active
        const [result] = await db.query(
            'UPDATE users SET is_active = 1 WHERE id = ? AND role = "client"',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            message: 'User approved successfully'
        });

    } catch (error) {
        console.error('Approve user error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Reject user (Admin only)
router.delete('/:id/reject', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { id } = req.params;

        // Delete the user
        const [result] = await db.query(
            'DELETE FROM users WHERE id = ? AND role = "client" AND is_active = 0',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found or already approved'
            });
        }

        res.json({
            success: true,
            message: 'User rejected and removed'
        });

    } catch (error) {
        console.error('Reject user error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Get current user profile
router.get('/me', authenticateToken, async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, role, balance, is_active FROM users WHERE id = ?',
            [req.user.id]
        );

        if (users.length === 0) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            data: users[0]
        });

    } catch (error) {
        console.error('Get user profile error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

module.exports = router;
