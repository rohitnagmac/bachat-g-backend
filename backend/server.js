const express = require('express');
const path = require('path');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./src/config/db');
const authRoutes = require('./src/routes/authRoutes');
const expenseRoutes = require('./src/routes/expenseRoutes');
const udhaarRoutes = require('./src/routes/udhaarRoutes');
const adminRoutes = require('./src/routes/adminRoutes');

dotenv.config();

const app = express();
const startServer = async () => {
    try {
        await connectDB();

        const PORT = process.env.PORT || 10000;
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
        });
    } catch (error) {
        console.error('Failed to connect to database:', error);
        process.exit(1);
    }
};

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

app.use('/api/auth', authRoutes);
app.use('/api/expenses', expenseRoutes);
app.use('/api/udhaar', udhaarRoutes);
app.use('/api/udhaar', udhaarRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/notifications', require('./src/routes/notificationRoutes'));

app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'OK', uptime: process.uptime() });
});

app.get('/', (req, res) => {
    res.send('API is running...');
});

startServer();
