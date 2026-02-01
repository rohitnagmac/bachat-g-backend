const mongoose = require('mongoose');
const User = require('./src/models/User');
const dotenv = require('dotenv');

dotenv.config();

const makeAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');

        // Find the user (assuming the user has logged in once via Google and has an email)
        // You can replace this with your specific email
        const email = 'rohitnag@example.com'; // REPLACE WITH USER'S EMAIL IF KNOWN, OR FIND FIRST USER

        // For now, let's just make the most recently created user an admin for testing
        const user = await User.findOne().sort({ createdAt: -1 });

        if (user) {
            user.role = 'admin';
            await user.save();
            console.log(`User ${user.email} (${user.fullName}) is now an ADMIN.`);
        } else {
            console.log('No users found.');
        }

        process.exit();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

makeAdmin();
