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
    },
    role: {
        type: String,
        enum: ['user', 'admin'],
        default: 'user'
    },
    otp: {
        type: String
    },
    otpExpires: {
        type: Date
    },
    deviceInfo: {
        type: Object, // Stores device model, manuf, etc.
        default: {}
    },
    ipAddress: {
        type: String
    },
    lastLogin: {
        type: Date
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('User', userSchema);
