/*!
 * where is worth diving - app.js
 */

/**
 * Module dependencies
 */

var config = require('./config');


// if (!config.debug) {
// 	require('newrelic');
// }

var path = require('path');
var Loader = require('loader');
var express = require('express');
var session = require('express-session');
var csurf = require('csurf');
var createServer = require("auto-sni");

require('./middlewares/mongoose_log'); // 打印 mongodb 查询日志
//var auth = require('./middlewares/auth');

var MongoStore = require('connect-mongo')(session);
var _ = require('lodash');//https://lodash.com/
var bodyParser = require('body-parser');
var compress = require('compression');
var busboy = require('connect-busboy');
var multer = require('multer');
var errorhandler = require('errorhandler');
var logger = require('./common/logger');

var fs = require('fs');
var http = require('http');
var https = require('https');
var privateKey;
var certificate;
var caContent;
var keyfileUrl = path.resolve(__dirname, config.keyfile);
var certfileUrl = path.resolve(__dirname, config.certfile);
var cafileUrl = path.resolve(__dirname, config.cafile);
if(!config.debug){
	keyfileUrl = config.keyfile;
	certfileUrl = config.certfile;
	cafileUrl = config.cafile;
}
if(fs.existsSync(keyfileUrl)) {
	privateKey  = fs.readFileSync(keyfileUrl, 'utf8');
}
if(fs.existsSync(certfileUrl)) {
	certificate = fs.readFileSync(certfileUrl, 'utf8');
}
if(fs.existsSync(cafileUrl)) {
	caContent = fs.readFileSync(cafileUrl, 'utf8');
}
var credentials;
if (privateKey && certificate && caContent) {
	credentials = {key: privateKey, cert: certificate, ca: caContent};
};



// 静态文件目录
var staticDir = path.join(__dirname, 'public');
// assets
var assets = {};

var urlinfo = require('url').parse(config.host);
config.hostname = urlinfo.hostname || config.host;

var app = express();

// configuration in all env
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');
app.engine('html', require('ejs-mate'));
//app.locals._layoutFile = 'layout.html';
app.enable('trust proxy');

//app.use(Loader.less());
app.use('/public', express.static(staticDir));

//app.use(require('response-time')); //打开这句，浏览器发请求无响应！很奇怪？？
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
	extended: true
}));
app.use(require('method-override')());
app.use(require('cookie-parser')(config.seesion_secret));
app.use(compress());
app.use(session({
	secret : config.session_secret,
	store : new MongoStore({
		url : config.db
	}),
	resave : true,
	saveUninitialized : true
}));

app.use(busboy({
	limits : {
		fileSize : 10 * 1024 * 1024 // 10MB
	}
}));

if (!config.debug) {
  app.use(function (req, res, next) {
    if (req.path.indexOf('/api') === -1) {
      csurf()(req, res, next);
      return;
    }
    next();
  });
  app.set('view cache', true);
}

// set static, dynamic helpers
_.extend(app.locals, {
  config: config,
  Loader: Loader,
  assets: assets
});

app.use(function (req, res, next) {
  res.locals.csrf = req.csrfToken ? req.csrfToken() : '';
  next();
});


// routes
var apiRouterV1 = require('./api_router_v1');
app.use('/api/v1', apiRouterV1);
var webRouter = require('./web_router');
app.use('/', webRouter);

// error handler
if(config.debug){
	app.use(errorhandler());
}


var httpsServer;
if(!config.debug && credentials){
	httpsServer = https.createServer(credentials, app);
	httpsServer.listen(config.port, function(){
		logger.log("aashare listening on port " + config.port + " in " + app.settings.env + " mode");
		logger.log("debug it with https://" + config.hostname + ":" + config.port);
		logger.log('');
	});
} else {
	app.listen(config.port, function(){
		logger.log("aashare listening on port " + config.port + " in " + app.settings.env + " mode");
		logger.log("debug it with http://" + config.hostname + ":" + config.port);
		logger.log('');
	});
}


// uer auto-sni to create https server
// https://github.com/DylanPiercey/auto-sni

// var server = createServer({
//     email: funpig@hotmail.com, // Emailed when certificates expire.
//     agreeTos: true, // Required for letsencrypt.
//     debug: true, // Add console messages and uses staging LetsEncrypt server. (Disable in production)
//     domains: ["funpigapp.com", "www.funpigapp.com"], // List of accepted domain names. (You can use nested arrays to register bundles with LE).
//     forceSSL: true, // Make this false to disable auto http->https redirects (default true).
//     redirectCode: 301, // If forceSSL is true, decide if redirect should be 301 (permanent) or 302 (temporary). Defaults to 302
//     ports: {
//         http: 80, // Optionally override the default http port.
//         https: 443 // // Optionally override the default https port.
//     }
// }, app);
// // Server is a "https.createServer" instance.
// server.once("listening", ()=> {
//     console.log("We are ready to go.");
// });



module.exports = app;

















