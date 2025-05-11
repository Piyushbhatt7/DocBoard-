const express = require("express");
const User = require("../models/user");

const authRouter = express.Router();

authRouter.post('api/sinup', async (req, res) => {

    try {
        const {name, email, profilPic} = req.body; // 1:10
        
        // email already exists?
        User.findById
        // store data
        // send response
    }

    catch (e)
    {

    }
})