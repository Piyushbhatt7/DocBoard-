const jwt = require('jsonwebtoken');

const { json } = require("express");
 
const auth = async (req, res, next) => {  
 
    try {                       
        const token = req.header("x-auth-token");                
  
        if(!token)  
        {
            return res.status(401).json({msg: "No auth token access denied"});

            const verified = jwt.verify(token, ); // 2:14
        }
    }
    catch(e)
    {

    }
}