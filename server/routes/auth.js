const express = require("express");
const User = require("../models/user");

const authRouter = express.Router();

authRouter.post('/signup', async (req, res) => {

    try {
        const {name, email, profilePic} = req.body; // 1:10
        
        // email already exists?
        let user = await User.findOne({
            email: email,
        });

        if(!user)
        {
            user = new User({
                email,
                profilePic,
                name,
            });
            user = await user.save();
        }
        // store data

        res.json({
            user: user,
        })
        // send response
    }

    catch (e)
    {
        console.error(e);
        res.status(500).json({ error: 'Something went wrong.' });
    }
});

module.exports = authRouter;