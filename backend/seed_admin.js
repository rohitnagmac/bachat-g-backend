const mongoose = require('mongoose');
const User = require('./src/models/User');
const dotenv = require('dotenv');

dotenv.config();

const seedAdmin = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');

        const email = 'rohitnag095@gmail.com';

        let user = await User.findOne({ email });

        if (!user) {
            console.log('Creating new admin user...');
            user = new User({
                email,
                googleId: 'manual_otp_' + Date.now(), // Dummy ID for manual users
                fullName: 'Rohit Nag',
                role: 'admin'
            });
        } else {
            console.log('Updating existing user to admin...');
            user.role = 'admin';
        }

        await user.save();
        console.log(`User ${user.email} is now an ADMIN.`);

        process.exit();
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
};

seedAdmin();
