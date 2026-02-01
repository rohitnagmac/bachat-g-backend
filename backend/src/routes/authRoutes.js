const express = require('express');
const router = express.Router();
const { googleAuth, googleAuthWeb, updateProfile, updateFcmToken } = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

router.post('/google', googleAuth);
router.post('/google-web', googleAuthWeb);
router.put('/profile', protect, updateProfile);
router.put('/fcm-token', protect, updateFcmToken);

module.exports = router;
