/**
 * config
 */

 var path = require('path');

 var config = {

 	// 通过NODE_ENV来设置环境变量，如果没有指定则默认为生产环境
	//env: process.env.NODE_ENV || 'production',
	//env = env.toLowerCase(),

 	//debug 为 true 时，用于本地调试
 	debug: true,

 	keyfile: 'ssl/privkey.pem',
    certfile: 'ssl/funpigapp.crt',
    cafile: 'ssl/xxx.pem',

	get mini_assets() { return !this.debug; }, // 是否启用静态文件的合并压缩，详见视图中的Loader

 	name: 'aa share', //aa share
 	description: '记录、分享',
 	keywords: 'aa, share, finance',

 	// cdn host, i.e http://xxx.qiniudn.com
 	site_static_host: '', //静态文件存储域名

 	//本地域名
 	host: 'localhost',
 	port: 7042,
 	wwwhost: 'http://127.0.0.1:7042',
 	sitetitle: 'Funpig\'s App',

 	// mongodb
 	db: 'mongodb://127.0.0.1/aashare',
 	db_name: 'aashare',

 	// redis 配置，默认是本地
  	redis_host: '127.0.0.1',
  	redis_port: 6379,
  	redis_db: 0,

 	//
 	session_secret: 'aashare_secret',
 	auth_cookie_name: 'aashare',

 	// newrelic 是个用来监控网站性能的服务
	newrelic_key: 'yourkey',

	//7牛的access信息，用于文件上传
	qn_access: {
	  accessKey: 'your access key',
	  secretKey: 'your secret key',
	  bucket: 'your bucket name',
	  domain: 'http://{bucket}.qiniudn.com'
	},

	//文件上传配置
	//注：如果填写 qn_access，则会上传到 7牛，以下配置无效
	upload: {
	  path: path.join(__dirname, 'public/upload/'),
	  url: '/public/upload/'
	},
 };

 module.exports = config;