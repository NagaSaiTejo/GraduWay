const User = require('../../core/models/User');
const { v4: uuidv4 } = require('uuid');

exports.signup = async (req, res) => {
    try {
        const userData = req.body;
        if (!userData.id) {
            userData.id = uuidv4();
        }
        const user = new User(userData);
        await user.save();
        res.status(201).json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};
