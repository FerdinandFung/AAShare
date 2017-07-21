var config = require('./config');
var express = require('express');
var site = require('./controllers/site');
var payproject = require('./controllers/payproject');

var router = express.Router();

// home page
router.get('/', site.home);

router.get('/payproject/detail/:pid', payproject.detail);

//router.get('/edit/country/:countrycode', edit.countrySelect);

module.exports = router;