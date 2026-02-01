const mongoose = require('mongoose');

const expenseSchema = mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User'
    },
    amount: {
        type: Number,
        required: true
    },
    category: {
        type: String, // e.g., Food, Travel, Rent
        required: true
    },
    date: {
        type: Date,
        default: Date.now
    },
    note: {
        type: String
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Expense', expenseSchema);
