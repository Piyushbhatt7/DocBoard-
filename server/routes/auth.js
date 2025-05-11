const express = require("express");

const authRouter = express.Router();

authRouter.post('api/sinup', async (req, res) => {

    try {
        const {name, email, profilPic} = req.body; // 1:10
        
        // email already exists?
        
        // store data
        // send response
    }

    catch (e)
    {

    }
})