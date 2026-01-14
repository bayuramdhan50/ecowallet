const express = require('express');
const router = express.Router();
const db = require('../config/database');
const auth = require('../middleware/auth');

/**
 * GET /api/analytics/user-stats
 * Get user statistics (Admin only)
 */
router.get('/user-stats', auth.authenticateToken, async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ error: 'Access denied' });
        }

        // Get total users by role and status
        const [userStats] = await db.query(`
            SELECT 
                role,
                is_active,
                COUNT(*) as count
            FROM users
            GROUP BY role, is_active
        `);

        // Get total user count
        const [totalUsers] = await db.query('SELECT COUNT(*) as total FROM users');

        res.json({
            userStats,
            totalUsers: totalUsers[0].total
        });
    } catch (error) {
        console.error('Error fetching user stats:', error);
        res.status(500).json({ error: 'Failed to fetch user statistics' });
    }
});

/**
 * GET /api/analytics/transaction-stats
 * Get transaction statistics (Admin only)
 */
router.get('/transaction-stats', auth.authenticateToken, async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ error: 'Access denied' });
        }

        // Get transaction counts by status
        const [statusStats] = await db.query(`
            SELECT 
                status,
                COUNT(*) as count,
                SUM(total_earning) as total_amount
            FROM transactions
            GROUP BY status
        `);

        // Get daily transaction trends (last 7 days)
        const [dailyTrends] = await db.query(`
            SELECT 
                DATE(created_at) as date,
                COUNT(*) as count,
                SUM(total_earning) as earning
            FROM transactions
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            GROUP BY DATE(created_at)
            ORDER BY date ASC
        `);

        // Get monthly trends (last 6 months)
        const [monthlyTrends] = await db.query(`
            SELECT 
                DATE_FORMAT(created_at, '%Y-%m') as month,
                COUNT(*) as count,
                SUM(total_earning) as earning
            FROM transactions
            WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
            GROUP BY DATE_FORMAT(created_at, '%Y-%m')
            ORDER BY month ASC
        `);

        // Get total stats
        const [totals] = await db.query(`
            SELECT 
                COUNT(*) as total_transactions,
                SUM(total_earning) as total_revenue,
                AVG(total_earning) as avg_transaction
            FROM transactions
            WHERE status = 'approved'
        `);

        res.json({
            statusStats,
            dailyTrends,
            monthlyTrends,
            totals: totals[0]
        });
    } catch (error) {
        console.error('Error fetching transaction stats:', error);
        res.status(500).json({ error: 'Failed to fetch transaction statistics' });
    }
});

/**
 * GET /api/analytics/waste-stats
 * Get waste type statistics (Admin only)
 */
router.get('/waste-stats', auth.authenticateToken, async (req, res) => {
    try {
        if (req.user.role !== 'admin') {
            return res.status(403).json({ error: 'Access denied' });
        }

        // Get waste type distribution
        const [wasteDistribution] = await db.query(`
            SELECT 
                wt.name,
                COUNT(t.id) as transaction_count,
                SUM(t.actual_weight) as total_weight,
                SUM(t.total_earning) as total_earning
            FROM waste_types wt
            LEFT JOIN transactions t ON wt.id = t.waste_type_id 
                AND t.status = 'approved'
            GROUP BY wt.id, wt.name
            ORDER BY transaction_count DESC
        `);

        res.json({
            wasteDistribution
        });
    } catch (error) {
        console.error('Error fetching waste stats:', error);
        res.status(500).json({ error: 'Failed to fetch waste statistics' });
    }
});

/**
 * GET /api/analytics/my-stats
 * Get personal statistics for current user (Client)
 */
router.get('/my-stats', auth.authenticateToken, async (req, res) => {
    try {
        const userId = req.user.id;

        // Get personal transaction stats
        const [personalStats] = await db.query(`
            SELECT 
                COUNT(*) as total_transactions,
                SUM(total_earning) as total_earning,
                AVG(total_earning) as avg_earning
            FROM transactions
            WHERE user_id = ? AND status = 'approved'
        `, [userId]);

        // Get monthly personal trends (last 6 months)
        const [monthlyTrends] = await db.query(`
            SELECT 
                DATE_FORMAT(created_at, '%Y-%m') as month,
                COUNT(*) as count,
                SUM(total_earning) as earning
            FROM transactions
            WHERE user_id = ? 
                AND created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH)
                AND status = 'approved'
            GROUP BY DATE_FORMAT(created_at, '%Y-%m')
            ORDER BY month ASC
        `, [userId]);

        // Get waste type breakdown for user
        const [wasteBreakdown] = await db.query(`
            SELECT 
                wt.name,
                COUNT(t.id) as count,
                SUM(t.total_earning) as earning
            FROM transactions t
            JOIN waste_types wt ON t.waste_type_id = wt.id
            WHERE t.user_id = ? AND t.status = 'approved'
            GROUP BY wt.id, wt.name
            ORDER BY count DESC
        `, [userId]);

        res.json({
            personalStats: personalStats[0],
            monthlyTrends,
            wasteBreakdown
        });
    } catch (error) {
        console.error('Error fetching personal stats:', error);
        res.status(500).json({ error: 'Failed to fetch personal statistics' });
    }
});

module.exports = router;
