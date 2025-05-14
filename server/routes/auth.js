const express = require("express");
const User = require("../models/user");
const jwt = require('jsonwebtoken');
const auth = require("../middlewares/auth");

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
        const token = jwt.sign({id: user._id}, "passwordKey");

        res.json({user, token});
        // store data

        res.status(200).json({
            user
        });  
        // send response
    }

    catch (e)
    {
        console.error(e);
        res.status(500).json({ error: 'Something went wrong.' });
    }
});

authRouter.get('/', auth, async (req, res) => {
   //// console.log(req.user);
   const user = await User.findById(req.user);
   res.json({user, token: req.token})
});

module.exports = authRouter;