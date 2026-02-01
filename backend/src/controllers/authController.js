const User = require('../models/User');
const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d',
    });
};

const googleAuth = async (req, res) => {
    const { token } = req.body;

    console.log('=== Google Auth Request ===');
    console.log('Received token:', token ? 'Present' : 'Missing');
    console.log('Token length:', token?.length);

    try {
        console.log('Verifying token with Google...');
        const ticket = await client.verifyIdToken({
            idToken: token,
            audience: process.env.GOOGLE_CLIENT_ID,
        });
        const { sub: googleId, email, name, picture } = ticket.getPayload();

        console.log('Token verified successfully');
        console.log('User email:', email);

        let user = await User.findOne({ googleId });

        if (!user) {
            console.log('Creating new user...');
            user = await User.create({
                googleId,
                email,
                fullName: name, // Default to Google name initially
                profilePicture: picture,
            });
            console.log('New user created:', user._id);
        } else {
            console.log('Existing user found:', user._id);
        }

        const responseData = {
            _id: user._id,
            fullName: user.fullName,
            email: user.email,
            mobileNumber: user.mobileNumber,
            profilePicture: user.profilePicture,
            isNewUser: !user.mobileNumber, // Flag to trigger profile completion
            token: generateToken(user._id),
        };

        console.log('Sending success response');
        res.json(responseData);
    } catch (error) {
        console.error('=== Google Auth Error ===');
        console.error('Error type:', error.constructor.name);
        console.error('Error message:', error.message);
        console.error('Full error:', error);
        res.status(400).json({ message: 'Google Auth Failed', error: error.message });
    }
};

const updateProfile = async (req, res) => {
    const user = await User.findById(req.user._id);

    if (user) {
        user.fullName = req.body.fullName || user.fullName;
        user.mobileNumber = req.body.mobileNumber || user.mobileNumber;
        user.profilePicture = req.body.profilePicture || user.profilePicture;

        const updatedUser = await user.save();

        res.json({
            _id: updatedUser._id,
            fullName: updatedUser.fullName,
            email: updatedUser.email,
            mobileNumber: updatedUser.mobileNumber,
            profilePicture: updatedUser.profilePicture,
            token: generateToken(updatedUser._id),
        });
    } else {
        res.status(404).json({ message: 'User not found' });
    }
};

// Web-specific authentication (fallback when idToken is not available)
const googleAuthWeb = async (req, res) => {
    const { email, name, photoUrl, id } = req.body;

    console.log('=== Google Auth Web Request ===');
    console.log('Email:', email);
    console.log('Name:', name);
    console.log('Google ID:', id);

    try {
        if (!email || !id) {
            return res.status(400).json({ message: 'Email and ID are required' });
        }

        let user = await User.findOne({ googleId: id });

        if (!user) {
            console.log('Creating new user from web auth...');
            user = await User.create({
                googleId: id,
                email,
                fullName: name || email.split('@')[0],
                profilePicture: photoUrl,
            });
            console.log('New user created:', user._id);
        } else {
            console.log('Existing user found:', user._id);
        }

        const responseData = {
            _id: user._id,
            fullName: user.fullName,
            email: user.email,
            mobileNumber: user.mobileNumber,
            profilePicture: user.profilePicture,
            isNewUser: !user.mobileNumber,
            token: generateToken(user._id),
        };

        console.log('Sending success response');
        res.json(responseData);
    } catch (error) {
        console.error('=== Google Auth Web Error ===');
        console.error('Error:', error.message);
        res.status(400).json({ message: 'Google Auth Failed', error: error.message });
    }
};

const updateFcmToken = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (user) {
            user.fcmToken = req.body.fcmToken;
            console.log(`Updating FCM Token for user ${user.email}: ${req.body.fcmToken}`);
            await user.save();
            res.json({ message: 'FCM token updated' });
        } else {
            res.status(404).json({ message: 'User not found' });
        }
    } catch (error) {
        res.status(400).json({ message: 'Failed to update FCM token', error: error.message });
    }
};

module.exports = { googleAuth, googleAuthWeb, updateProfile, updateFcmToken };
