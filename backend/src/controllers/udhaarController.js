const Udhaar = require('../models/Udhaar');

// Create new udhaar entry
const createUdhaar = async (req, res) => {
    const { type, personName, amount, date, notes } = req.body;

    console.log('=== Create Udhaar Request ===');
    console.log('User:', req.user._id);
    console.log('Type:', type);
    console.log('Person:', personName);
    console.log('Amount:', amount);

    try {
        if (!type || !personName || !amount) {
            return res.status(400).json({ message: 'Type, person name, and amount are required' });
        }

        if (!['LENE', 'DENE'].includes(type)) {
            return res.status(400).json({ message: 'Type must be LENE or DENE' });
        }

        const udhaar = await Udhaar.create({
            user: req.user._id,
            type,
            personName,
            amount,
            date: date || new Date(),
            notes,
            isSettled: false,
        });

        console.log('Udhaar created:', udhaar._id);
        res.status(201).json(udhaar);
    } catch (error) {
        console.error('Create Udhaar Error:', error.message);
        res.status(400).json({ message: 'Failed to create udhaar', error: error.message });
    }
};

// Get user's udhaar entries
const getUdhaars = async (req, res) => {
    const { type, isSettled } = req.query;

    console.log('=== Get Udhaar Request ===');
    console.log('User:', req.user._id);
    console.log('Filters:', { type, isSettled });

    try {
        const filter = { user: req.user._id };

        // Filter by type (LENE/DENE)
        if (type) {
            filter.type = type;
        }

        // Filter by settled status
        if (isSettled !== undefined) {
            filter.isSettled = isSettled === 'true';
        }

        const udhaars = await Udhaar.find(filter).sort({ date: -1 });

        console.log(`Found ${udhaars.length} udhaar entries`);
        res.json(udhaars);
    } catch (error) {
        console.error('Get Udhaar Error:', error.message);
        res.status(400).json({ message: 'Failed to fetch udhaar', error: error.message });
    }
};

// Update udhaar entry
const updateUdhaar = async (req, res) => {
    const { id } = req.params;
    const { personName, amount, date, notes, isSettled } = req.body;

    console.log('=== Update Udhaar Request ===');
    console.log('Udhaar ID:', id);

    try {
        const udhaar = await Udhaar.findOne({ _id: id, user: req.user._id });

        if (!udhaar) {
            return res.status(404).json({ message: 'Udhaar not found' });
        }

        udhaar.personName = personName || udhaar.personName;
        udhaar.amount = amount || udhaar.amount;
        udhaar.date = date || udhaar.date;
        udhaar.notes = notes !== undefined ? notes : udhaar.notes;
        udhaar.isSettled = isSettled !== undefined ? isSettled : udhaar.isSettled;

        await udhaar.save();

        console.log('Udhaar updated:', udhaar._id);
        res.json(udhaar);
    } catch (error) {
        console.error('Update Udhaar Error:', error.message);
        res.status(400).json({ message: 'Failed to update udhaar', error: error.message });
    }
};

// Delete udhaar entry
const deleteUdhaar = async (req, res) => {
    const { id } = req.params;

    console.log('=== Delete Udhaar Request ===');
    console.log('Udhaar ID:', id);

    try {
        const udhaar = await Udhaar.findOneAndDelete({ _id: id, user: req.user._id });

        if (!udhaar) {
            return res.status(404).json({ message: 'Udhaar not found' });
        }

        console.log('Udhaar deleted:', id);
        res.json({ message: 'Udhaar deleted successfully' });
    } catch (error) {
        console.error('Delete Udhaar Error:', error.message);
        res.status(400).json({ message: 'Failed to delete udhaar', error: error.message });
    }
};

module.exports = {
    createUdhaar,
    getUdhaars,
    updateUdhaar,
    deleteUdhaar,
};
