const nodemailer = require('nodemailer');

const sendOTP = async (email, otp) => {
    const transporter = nodemailer.createTransport({
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        secure: process.env.SMTP_PORT == 465, // true for 465, false for other ports
        auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
        },
    });

    const mailOptions = {
        from: `"Bachat-G Admin" <${process.env.SMTP_USER}>`,
        to: email,
        subject: 'Your Bachat-G Admin OTP',
        text: `Your OTP for Bachat-G Admin login is: ${otp}. It is valid for 10 minutes.`,
        html: `
            <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 5px;">
                <h2 style="color: #6200ee;">Bachat-G Admin Login</h2>
                <p>Use the following One-Time Password (OTP) to access your account:</p>
                <div style="font-size: 24px; font-weight: bold; color: #6200ee; padding: 10px; background: #f4f4f4; border-radius: 5px; display: inline-block;">
                    ${otp}
                </div>
                <p>This OTP is valid for 10 minutes. If you did not request this code, please ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #eee;" />
                <p style="font-size: 12px; color: #777;">Bachat-G Team</p>
            </div>
        `,
    };

    try {
        const info = await transporter.sendMail(mailOptions);
        console.log('Email sent: %s', info.messageId);
        return true;
    } catch (error) {
        console.error('Error sending email:', error);
        return false;
    }
};

module.exports = { sendOTP };
