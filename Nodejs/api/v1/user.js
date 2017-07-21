var models = require('../../models');
var UserProxy = require('../../proxy').User;
var config = require('../../config');
var eventproxy = require('eventproxy');
var _ = require('lodash');
var validator = require('validator');

// input: {nick_name: "nickname", login_name: "login name", password: "password"}
// output: {code: 0, msg: 'successful'}
var login = function (req, res, next) {
	var login_name = req.body.login_name;
	var password = req.body.password;

	var editError;
	if (typeof(login_name) == 'undefined' || login_name === '') {
		editError = '登录名不可为空';
	}else if (typeof(password) == 'undefined' || password === '') {
		editError = '密码不可为空';
	}

	if (editError) {
		res.status(422);
		return res.send({
			"code": -1,
			"msg": editError
		});
	}

	var ep = new eventproxy();
	ep.fail(next);

	UserProxy.getUserByLoginNameAndPassword(login_name, password, function(err, user){
		if (!user){
			return res.send({code: -1, msg: "用户名或密码错误！"});
		}

		user = _.pick(user, ['id', 'nick_name', 'token', 'favorite_divesite']);
		res.send({
				"code": 0,
				"msg": "successful",
				"data": user
			});
	});
};

exports.login = login;

var register = function (req, res, next) {
	var nick_name = req.body.nick_name;
	var login_name = req.body.login_name;
	var password = req.body.password;
	var isthirdpartylogin = req.body.isthirdpartylogin;

	var editError;
	if (typeof(nick_name) == 'undefined' || nick_name === '') {
		editError = '昵称不可为空'
	}else if (typeof(login_name) == 'undefined' || login_name === '') {
		editError = '登录名不可为空';
	}else if (!validator.isEmail(login_name)) {
		editError = 'email地址不合法！';
	}else if (typeof(password) == 'undefined' || password === '') {
		editError = '密码不可为空';
	}

	if (editError) {
		res.status(422);
		return res.send({
			"code": -1,
			"msg": editError
		});
	}

	var ep = new eventproxy();
	ep.fail(next);

	UserProxy.getUserByLoginName(login_name, ep.done(function(user){
		if (user) 
		{
			return res.send({
				"code": -1,
				"msg": "登录名已存在！不能重复注册。"
			});
		}
		else
		{
			ep.emit('author_not_exist');
		}
	}));

 	ep.all('author_not_exist', function(){
 		UserProxy.newAndSave(nick_name, login_name, password, isthirdpartylogin, function(err, user){
 			user = _.pick(user, ['id', 'login_name', 'nick_name', 'token', 'favorite_divesite']);
			return res.send({
				"code": 0,
				"msg": "successful",
				"data": user
			});
		})
 	});
	
};

exports.register = register;
