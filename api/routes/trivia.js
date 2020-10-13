var express = require("express");
var router = express.Router();
const axios = require('axios');

router.get("/", function (req, res, next) {
  axios.get("https://opentdb.com/api.php?amount=3&category=18&type=multiple")
    .then(result => {
      console.log(result.data);
      res.send(result.data.results);
    })
    .catch((error) => {
      // handle error
      console.log(error);
    });
});

module.exports = router;
