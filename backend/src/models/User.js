const mongoose = require('mongoose');

const userSchema = mongoose.Schema({
    googleId: {
        type: String,
        required: true,
        unique: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    fullName: {
        type: String,
        required: false // Collected after login
    },
    mobileNumber: {
        type: String,
        required: false // Collected after login
    },
    profilePicture: {
        type: String
    },
    fcmToken: {
        type: String
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('User', userSchema);
