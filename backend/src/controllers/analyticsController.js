const UserActivity = require('../models/UserActivity');
const User = require('../models/User');

// Record user activity
const recordActivity = async (req, res) => {
    try {
        const { type, duration, metadata } = req.body;

        if (type === 'app_open') {
            await User.findByIdAndUpdate(req.user._id, { lastLogin: new Date() });
        }

        await UserActivity.create({
            user: req.user._id,
            type,
            duration: duration || 0,
            metadata,
            date: new Date()
        });

        res.status(201).json({ message: 'Activity recorded' });
    } catch (error) {
        console.error('Record Activity Error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

// Get Admin Analytics (Date-wise)
const getAnalytics = async (req, res) => {
    try {
        const { days = 7 } = req.query; // Default to last 7 days
        const endDate = new Date();
        const startDate = new Date();
        startDate.setDate(endDate.getDate() - parseInt(days));
        startDate.setHours(0, 0, 0, 0);

        // 1. New Users per day
        const newUsers = await User.aggregate([
            { $match: { createdAt: { $gte: startDate, $lte: endDate }, role: 'user' } },
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$createdAt" } },
                    count: { $sum: 1 }
                }
            },
            { $sort: { _id: 1 } }
        ]);

        // 2. Active Users per day (Unique users who opened the app)
        const activeUsers = await UserActivity.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate }, type: 'app_open' } },
            {
                $group: {
                    _id: {
                        date: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                        user: "$user"
                    }
                }
            },
            {
                $group: {
                    _id: "$_id.date",
                    count: { $sum: 1 }
                }
            },
            { $sort: { _id: 1 } }
        ]);

        // 3. Average Session Duration per day
        const avgSessionDuration = await UserActivity.aggregate([
            { $match: { date: { $gte: startDate, $lte: endDate }, type: 'session' } },
            {
                $group: {
                    _id: { $dateToString: { format: "%Y-%m-%d", date: "$date" } },
                    avgDuration: { $avg: "$duration" }, // In seconds
                    totalSessions: { $sum: 1 }
                }
            },
            { $sort: { _id: 1 } }
        ]);

        res.json({
            newUsers,
            activeUsers,
            avgSessionDuration
        });

    } catch (error) {
        console.error('Get Analytics Error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = {
    recordActivity,
    getAnalytics
};
