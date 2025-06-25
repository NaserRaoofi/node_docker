const express = require("express");

const app = express();

app.get("/", (req, res) => {
  res.send("<h2>Hello Sirwan! Nodemon is working! 🚀 sirwan raoofi</h2>");
});

const port = process.env.PORT || 3000;

app.listen(port, "0.0.0.0", () => console.log(`listening on port ${port}`));
