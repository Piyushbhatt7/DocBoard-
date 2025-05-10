console.log('Hello, World')
const express = require("express");
const mangoose = require("mongoose");

const PORT = process.env.PORT | 3001;

const app = express();

const DB = "";

mongoose.connect(DB);

app.listen(PORT, "0.0.0.0", () => {
    console.log('connected at port 3001');
    console.log("hey this is changing");
})