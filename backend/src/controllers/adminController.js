const User = require('../models/User');
const Expense = require('../models/Expense');
const Udhaar = require('../models/Udhaar');

// Get global platform stats
const getStats = async (req, res) => {
    try {
        const totalUsers = await User.countDocuments();

        // Calculate total monthly expense volume (across all users)
        // For simplicity, let's get total expenses of current month
        const now = new Date();
        const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

        const expenseStats = await Expense.aggregate([
            { $match: { date: { $gte: startOfMonth } } },
            { $group: { _id: null, total: { $sum: '$amount' } } }
        ]);
        const totalMonthlyExpenses = expenseStats[0]?.total || 0;

        // Total Active Udhaar (not settled)
        const udhaarStats = await Udhaar.aggregate([
            { $match: { isSettled: false } },
            { $group: { _id: null, total: { $sum: '$amount' } } }
        ]);
        const totalActiveUdhaar = udhaarStats[0]?.total || 0;

        res.json({
            totalUsers,
            totalMonthlyExpenses,
            totalActiveUdhaar
        });
    } catch (error) {
        console.error('Admin Stats Error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await User.find({ role: 'user' })
            .select('-password -otp -otpExpires')
            .sort({ createdAt: -1 });

        res.json(users);
    } catch (error) {
        console.error('Error fetching users:', error);
        res.status(500).json({ message: 'Server error' });
    }
};

module.exports = {
    getStats,
    getAllUsers
};
