const express = require('express');
const Document = require('../modules/document_model');
const documentRouter = express.Router();
const auth = require('../middlewares/auth');
const e = require('express');


documentRouter.post('/doc/create', auth, async(req, res) => {

    try{

    }
    catch(e)
    {
        res.status(500).json({error: e.message})
    }
}); 