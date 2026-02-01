const mongoose = require('mongoose');

const userActivitySchema = mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
    type: {
        type: String,
        enum: ['app_open', 'session'], // 'app_open' = app launched/resumed, 'session' = duration recorded
        required: true
    },
    duration: {
        type: Number, // In seconds (relevant for 'session' type)
        default: 0
    },
    date: {
        type: Date,
        default: Date.now
    },
    metadata: {
        type: Object // Store device info or other context if needed
    }
}, {
    timestamps: true
});

// Index for efficient querying by date and user
userActivitySchema.index({ date: 1, user: 1 });

module.exports = mongoose.model('UserActivity', userActivitySchema);
