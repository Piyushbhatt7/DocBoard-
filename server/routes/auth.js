const express = require("express");
const User = require("../models/user");

const authRouter = express.Router();

authRouter.post('api/sinup', async (req, res) => {

    try {
        const {name, email, profilPic} = req.body; // 1:10
        
        // email already exists?
        let user = User.findOne({
            email: email,
        });
        // store data
        // send response
    }

    catch (e)
    {

    }
})