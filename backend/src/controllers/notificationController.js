const admin = require('firebase-admin');
const User = require('../models/User');

let isFirebaseInitialized = false;

try {
    const serviceAccount = require('../../serviceAccountKey.json');
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    isFirebaseInitialized = true;
    console.log('Firebase Admin Initialized');
} catch (error) {
    console.warn('Firebase Admin Setup Failed: serviceAccountKey.json not found in backend root. Notifications will fail.');
}

const sendNotification = async (req, res) => {
    try {
        if (!isFirebaseInitialized) {
            return res.status(503).json({ message: 'Firebase not configured on server' });
        }

        const { title, body, targetUserIds } = req.body;
        let imageUrl = req.body.imageUrl;

        // If a file was uploaded, overwrite imageUrl with the local server path
        if (req.file) {
            imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
        }

        const userIds = targetUserIds ? (Array.isArray(targetUserIds) ? targetUserIds : [targetUserIds]) : [];
        let tokens = [];

        if (userIds.length > 0) {
            // Send to specific users
            const users = await User.find({ _id: { $in: userIds }, fcmToken: { $exists: true, $ne: null } });
            tokens = users.map(u => u.fcmToken);
        } else {
            // Send to ALL users who have a token
            const users = await User.find({ fcmToken: { $exists: true, $ne: null } });
            tokens = users.map(u => u.fcmToken);
        }

        if (tokens.length === 0) {
            return res.status(404).json({ message: 'No devices found to send notification' });
        }

        // Send multicast message
        const message = {
            notification: {
                title: title || 'Bachat-G Admin',
                body,
                ...(imageUrl && { imageUrl })
            },
            tokens: tokens
        };

        const response = await admin.messaging().sendEachForMulticast(message);
        console.log('Notification sent:', response);

        res.json({
            message: 'Notification sent successfully',
            successCount: response.successCount,
            failureCount: response.failureCount
        });

    } catch (error) {
        console.error('Send Notification Error:', error);
        res.status(500).json({ message: 'Server Error' });
    }
};

module.exports = { sendNotification };
