const Expense = require('../models/Expense');

// Create new expense
const createExpense = async (req, res) => {
    const { amount, category, date, notes } = req.body;

    console.log('=== Create Expense Request ===');
    console.log('User:', req.user._id);
    console.log('Amount:', amount);
    console.log('Category:', category);

    try {
        if (!amount || !category) {
            return res.status(400).json({ message: 'Amount and category are required' });
        }

        const expense = await Expense.create({
            user: req.user._id,
            amount,
            category,
            date: date || new Date(),
            notes,
        });

        console.log('Expense created:', expense._id);
        res.status(201).json(expense);
    } catch (error) {
        console.error('Create Expense Error:', error.message);
        res.status(400).json({ message: 'Failed to create expense', error: error.message });
    }
};

// Get user's expenses
const getExpenses = async (req, res) => {
    const { startDate, endDate, category } = req.query;

    console.log('=== Get Expenses Request ===');
    console.log('User:', req.user._id);
    console.log('Filters:', { startDate, endDate, category });

    try {
        const filter = { user: req.user._id };

        // Add date range filter
        if (startDate || endDate) {
            filter.date = {};
            if (startDate) filter.date.$gte = new Date(startDate);
            if (endDate) filter.date.$lte = new Date(endDate);
        }

        // Add category filter
        if (category) {
            filter.category = category;
        }

        const expenses = await Expense.find(filter).sort({ date: -1 });

        console.log(`Found ${expenses.length} expenses`);
        res.json(expenses);
    } catch (error) {
        console.error('Get Expenses Error:', error.message);
        res.status(400).json({ message: 'Failed to fetch expenses', error: error.message });
    }
};

// Update expense
const updateExpense = async (req, res) => {
    const { id } = req.params;
    const { amount, category, date, notes } = req.body;

    console.log('=== Update Expense Request ===');
    console.log('Expense ID:', id);

    try {
        const expense = await Expense.findOne({ _id: id, user: req.user._id });

        if (!expense) {
            return res.status(404).json({ message: 'Expense not found' });
        }

        expense.amount = amount || expense.amount;
        expense.category = category || expense.category;
        expense.date = date || expense.date;
        expense.notes = notes !== undefined ? notes : expense.notes;

        await expense.save();

        console.log('Expense updated:', expense._id);
        res.json(expense);
    } catch (error) {
        console.error('Update Expense Error:', error.message);
        res.status(400).json({ message: 'Failed to update expense', error: error.message });
    }
};

// Delete expense
const deleteExpense = async (req, res) => {
    const { id } = req.params;

    console.log('=== Delete Expense Request ===');
    console.log('Expense ID:', id);

    try {
        const expense = await Expense.findOneAndDelete({ _id: id, user: req.user._id });

        if (!expense) {
            return res.status(404).json({ message: 'Expense not found' });
        }

        console.log('Expense deleted:', id);
        res.json({ message: 'Expense deleted successfully' });
    } catch (error) {
        console.error('Delete Expense Error:', error.message);
        res.status(400).json({ message: 'Failed to delete expense', error: error.message });
    }
};

// Get expense statistics (grouped by category for pie chart)
const getExpenseStats = async (req, res) => {
    const { startDate, endDate } = req.query;

    console.log('=== Get Expense Stats Request ===');
    console.log('User:', req.user._id);

    try {
        const userId = req.user._id;

        // 1. Calculate Periodic Totals
        const now = new Date();
        const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());

        // Start of current week (assuming Monday as start)
        const day = now.getDay();
        const diff = now.getDate() - day + (day === 0 ? -6 : 1);
        const startOfWeek = new Date(now.setDate(diff));
        startOfWeek.setHours(0, 0, 0, 0);

        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const [todayStats, weekStats, monthStats] = await Promise.all([
            Expense.aggregate([
                { $match: { user: userId, date: { $gte: startOfToday } } },
                { $group: { _id: null, total: { $sum: '$amount' } } }
            ]),
            Expense.aggregate([
                { $match: { user: userId, date: { $gte: startOfWeek } } },
                { $group: { _id: null, total: { $sum: '$amount' } } }
            ]),
            Expense.aggregate([
                { $match: { user: userId, date: { $gte: startOfMonth } } },
                { $group: { _id: null, total: { $sum: '$amount' } } }
            ])
        ]);

        // 2. Category Breakdown (for the requested date range or default to month)
        const statsFilter = { user: userId };
        if (startDate || endDate) {
            statsFilter.date = {};
            if (startDate) statsFilter.date.$gte = new Date(startDate);
            if (endDate) statsFilter.date.$lte = new Date(endDate);
        } else {
            // Default breakdown for current month
            statsFilter.date = { $gte: startOfMonth };
        }

        const categoryStats = await Expense.aggregate([
            { $match: statsFilter },
            {
                $group: {
                    _id: '$category',
                    total: { $sum: '$amount' },
                    count: { $sum: 1 },
                },
            },
            { $sort: { total: -1 } },
        ]);

        const totalForBreakdown = categoryStats.reduce((sum, cat) => sum + cat.total, 0);

        const pieChartData = categoryStats.map((cat) => ({
            category: cat._id,
            amount: cat.total,
            count: cat.count,
            percentage: totalForBreakdown > 0 ? ((cat.total / totalForBreakdown) * 100).toFixed(2) : 0,
        }));

        res.json({
            today: todayStats[0]?.total || 0,
            week: weekStats[0]?.total || 0,
            month: monthStats[0]?.total || 0,
            total: totalForBreakdown,
            categoryBreakdown: pieChartData,
        });
    } catch (error) {
        console.error('Get Stats Error:', error.message);
        res.status(400).json({ message: 'Failed to fetch statistics', error: error.message });
    }
};

module.exports = {
    createExpense,
    getExpenses,
    updateExpense,
    deleteExpense,
    getExpenseStats,
};
