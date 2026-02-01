const express = require('express');
const router = express.Router();
const { recordActivity, getAnalytics } = require('../controllers/analyticsController');
const { protect, admin } = require('../middleware/authMiddleware');

// User routes
router.post('/activity', protect, recordActivity);

// Admin routes
router.get('/admin', protect, admin, getAnalytics);

module.exports = router;
