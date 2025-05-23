const jwt = require('jsonwebtoken');

const { json } = require("express");
 
const auth = async (req, res, next) => {  
 
    try {                                            
        const token = req.header("x-auth-token");                
  
        if(!token)  
        
            return res.status(401).json({msg: "No auth token access denied"});

            const verified = jwt.verify(token, "passwordKey"); // 2:14

            if(!verified)
                return res
            .status(401)
            .json({msg: 'Token verification failed, authorization failed'});
        
            req.user = verified.id;
            req.token = token;
            next();
    }
    catch(e)
    {
        res.status(500).json({erro: e.message});
    }
};

module.exports = auth;