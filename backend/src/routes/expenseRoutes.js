const express = require('express');
const router = express.Router();
const {
    createExpense,
    getExpenses,
    updateExpense,
    deleteExpense,
    getExpenseStats,
} = require('../controllers/expenseController');
const { protect } = require('../middleware/authMiddleware');

// All routes require authentication
router.use(protect);

router.post('/', createExpense);
router.get('/', getExpenses);
router.get('/stats', getExpenseStats);
router.put('/:id', updateExpense);
router.delete('/:id', deleteExpense);

module.exports = router;
