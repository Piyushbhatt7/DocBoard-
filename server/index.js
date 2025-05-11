console.log('Hello, World')
const express = require("express");
const mongoose = require("mongoose");

const PORT = process.env.PORT || 3001;

const app = express();

app.use(authRouter);

const DB = "mongodb+srv://piyushbhatt162:0k0P2FcurljxejUR@cluster0.mrjbpoh.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0";

mongoose.connect(DB)
.then(() => {
    console.log("Connection successful !");
})
.catch((err) => {
    console.log(err);

});

// async -> await
// .then((ref) => print(ref)


app.listen(PORT, "0.0.0.0", () => {
    console.log('connected at port 3001');
    console.log("hey this is changing");
});