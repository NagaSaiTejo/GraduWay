const User = require('../models/User');
const { v4: uuidv4 } = require('uuid');

exports.login = async (req, res) => {
    try {
        const { email, name } = req.body;
        let user = await User.findOne({ email });
        
        if (!user) {
            // Auto-register for demo purposes (matching Spring Boot logic)
            user = new User({
                id: uuidv4(),
                email: email,
                name: name || email.split('@')[0],
                // Other fields would be added via signup or profile update
            });
            await user.save();
        }
        
        res.status(200).json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

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
