const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Get all waste types (Public - for client to see options)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const [wasteTypes] = await db.query(
            'SELECT * FROM waste_types ORDER BY name ASC'
        );

        res.json({
            success: true,
            data: wasteTypes
        });

    } catch (error) {
        console.error('Get waste types error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Create waste type (Admin only)
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { name, price_per_kg, bonus_threshold, bonus_amount } = req.body;

        // Validation
        if (!name || !price_per_kg) {
            return res.status(400).json({
                success: false,
                message: 'Name and price are required'
            });
        }

        const [result] = await db.query(
            'INSERT INTO waste_types (name, price_per_kg, bonus_threshold, bonus_amount) VALUES (?, ?, ?, ?)',
            [name, price_per_kg, bonus_threshold || 0, bonus_amount || 0]
        );

        res.status(201).json({
            success: true,
            message: 'Waste type created successfully',
            data: {
                id: result.insertId,
                name,
                price_per_kg,
                bonus_threshold: bonus_threshold || 0,
                bonus_amount: bonus_amount || 0
            }
        });

    } catch (error) {
        console.error('Create waste type error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Update waste type (Admin only)
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        const { name, price_per_kg, bonus_threshold, bonus_amount } = req.body;

        const [result] = await db.query(
            'UPDATE waste_types SET name = ?, price_per_kg = ?, bonus_threshold = ?, bonus_amount = ? WHERE id = ?',
            [name, price_per_kg, bonus_threshold || 0, bonus_amount || 0, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Waste type not found'
            });
        }

        res.json({
            success: true,
            message: 'Waste type updated successfully'
        });

    } catch (error) {
        console.error('Update waste type error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Delete waste type (Admin only)
router.delete('/:id', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const { id } = req.params;

        const [result] = await db.query(
            'DELETE FROM waste_types WHERE id = ?',
            [id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Waste type not found'
            });
        }

        res.json({
            success: true,
            message: 'Waste type deleted successfully'
        });

    } catch (error) {
        console.error('Delete waste type error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

module.exports = router;
