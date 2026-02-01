const express = require('express');
const router = express.Router();
const {
    createUdhaar,
    getUdhaars,
    updateUdhaar,
    deleteUdhaar,
} = require('../controllers/udhaarController');
const { protect } = require('../middleware/authMiddleware');

// All routes require authentication
router.use(protect);

router.post('/', createUdhaar);
router.get('/', getUdhaars);
router.put('/:id', updateUdhaar);
router.delete('/:id', deleteUdhaar);

module.exports = router;
