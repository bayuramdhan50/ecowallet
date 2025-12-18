const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { v4: uuidv4 } = require('uuid');
const db = require('../config/database');
const { authenticateToken, requireAdmin } = require('../middleware/auth');

// Configure multer for photo uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        const uniqueName = `${uuidv4()}${path.extname(file.originalname)}`;
        cb(null, uniqueName);
    }
});

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
    fileFilter: (req, file, cb) => {
        // Accept any image type from camera
        if (file.mimetype.startsWith('image/')) {
            return cb(null, true);
        }
        cb(new Error('Only image files are allowed'));
    }
});

// Submit deposit request (Client)
router.post('/', authenticateToken, upload.single('photo'), async (req, res) => {
    try {
        const { waste_type_id, estimated_weight } = req.body;
        const user_id = req.user.id;
        const photo_url = req.file ? `/uploads/${req.file.filename}` : null;

        // Validation
        if (!waste_type_id || !estimated_weight) {
            return res.status(400).json({
                success: false,
                message: 'Waste type and estimated weight are required'
            });
        }

        // Insert transaction
        const [result] = await db.query(
            'INSERT INTO transactions (user_id, waste_type_id, estimated_weight, photo_url, status) VALUES (?, ?, ?, ?, ?)',
            [user_id, waste_type_id, estimated_weight, photo_url, 'pending']
        );

        res.status(201).json({
            success: true,
            message: 'Deposit request submitted successfully',
            data: {
                id: result.insertId,
                waste_type_id,
                estimated_weight,
                photo_url,
                status: 'pending'
            }
        });

    } catch (error) {
        console.error('Submit deposit error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Get user's transactions (Client)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const user_id = req.user.id;

        const [transactions] = await db.query(`
      SELECT 
        t.id,
        t.user_id,
        t.waste_type_id,
        wt.name as waste_type_name,
        t.estimated_weight,
        t.actual_weight,
        t.photo_url,
        t.total_earning,
        t.status,
        t.created_at,
        t.updated_at
      FROM transactions t
      JOIN waste_types wt ON t.waste_type_id = wt.id
      WHERE t.user_id = ?
      ORDER BY t.created_at DESC
    `, [user_id]);

        res.json({
            success: true,
            data: transactions
        });

    } catch (error) {
        console.error('Get transactions error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Get pending transactions (Admin)
router.get('/pending', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const [transactions] = await db.query(`
      SELECT 
        t.id,
        t.user_id,
        u.name as user_name,
        u.email as user_email,
        t.waste_type_id,
        wt.name as waste_type_name,
        wt.price_per_kg,
        wt.bonus_threshold,
        wt.bonus_amount,
        t.estimated_weight,
        t.actual_weight,
        t.photo_url,
        t.total_earning,
        t.status,
        t.created_at
      FROM transactions t
      JOIN users u ON t.user_id = u.id
      JOIN waste_types wt ON t.waste_type_id = wt.id
      WHERE t.status = 'pending'
      ORDER BY t.created_at ASC
    `);

        res.json({
            success: true,
            data: transactions
        });

    } catch (error) {
        console.error('Get pending transactions error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    }
});

// Validate transaction with calculation logic (Admin)
// SubCPMK 3: Mathematical calculation and logic
router.put('/:id/validate', authenticateToken, requireAdmin, async (req, res) => {
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        const { id } = req.params;
        const { actual_weight, action } = req.body; // action: 'approve' or 'reject'

        // Validation
        if (!action || !['approve', 'reject'].includes(action)) {
            await connection.rollback();
            return res.status(400).json({
                success: false,
                message: 'Action must be "approve" or "reject"'
            });
        }

        if (action === 'approve' && !actual_weight) {
            await connection.rollback();
            return res.status(400).json({
                success: false,
                message: 'Actual weight is required for approval'
            });
        }

        // Get transaction with waste type info
        const [transactions] = await connection.query(`
      SELECT 
        t.*,
        wt.price_per_kg,
        wt.bonus_threshold,
        wt.bonus_amount
      FROM transactions t
      JOIN waste_types wt ON t.waste_type_id = wt.id
      WHERE t.id = ? AND t.status = 'pending'
    `, [id]);

        if (transactions.length === 0) {
            await connection.rollback();
            return res.status(404).json({
                success: false,
                message: 'Transaction not found or already processed'
            });
        }

        const transaction = transactions[0];

        if (action === 'reject') {
            // Simply mark as rejected
            await connection.query(
                'UPDATE transactions SET status = ?, updated_at = NOW() WHERE id = ?',
                ['rejected', id]
            );

            await connection.commit();

            return res.json({
                success: true,
                message: 'Transaction rejected successfully',
                data: {
                    id,
                    status: 'rejected'
                }
            });
        }

        // === CALCULATION LOGIC (SubCPMK 3) ===
        // If actual_weight > bonus_threshold, add bonus to price
        let effectivePricePerKg = transaction.price_per_kg;
        let bonusApplied = false;

        if (parseFloat(actual_weight) > parseFloat(transaction.bonus_threshold)) {
            effectivePricePerKg = parseFloat(transaction.price_per_kg) + parseFloat(transaction.bonus_amount);
            bonusApplied = true;
        }

        // Calculate total earning
        const totalEarning = parseFloat(actual_weight) * effectivePricePerKg;

        // Update transaction
        await connection.query(
            'UPDATE transactions SET actual_weight = ?, total_earning = ?, status = ?, updated_at = NOW() WHERE id = ?',
            [actual_weight, totalEarning, 'approved', id]
        );

        // Update user balance
        await connection.query(
            'UPDATE users SET balance = balance + ? WHERE id = ?',
            [totalEarning, transaction.user_id]
        );

        await connection.commit();

        res.json({
            success: true,
            message: 'Transaction approved and calculated successfully',
            data: {
                id,
                actual_weight: parseFloat(actual_weight),
                base_price_per_kg: parseFloat(transaction.price_per_kg),
                bonus_applied: bonusApplied,
                bonus_amount: bonusApplied ? parseFloat(transaction.bonus_amount) : 0,
                effective_price_per_kg: effectivePricePerKg,
                total_earning: totalEarning,
                status: 'approved'
            }
        });

    } catch (error) {
        await connection.rollback();
        console.error('Validate transaction error:', error);
        res.status(500).json({
            success: false,
            message: 'Server error'
        });
    } finally {
        connection.release();
    }
});

module.exports = router;
