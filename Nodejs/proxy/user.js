var models = require('../models');
var User = models.User;
var utility = require('utility');
var uuid = require('uuid');

/**
 * 根据昵称查找用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} name 昵称
 * @param {Function} callback 回调函数
 */
exports.getUserByName = function (name, callback) {
    if (name.length === 0) {
        return callback(null, null);
    }
    User.findOne({nick_name: name}, callback);
};

/**
 * 根据昵称列表查找用户列表
 * Callback:
 * - err, 数据库异常
 * - users, 用户列表
 * @param {Array} names 昵称列表
 * @param {Function} callback 回调函数
 */
exports.getUsersByNames = function (names, callback) {
    if (names.length === 0) {
        return callback(null, []);
    }
    User.find({nick_name: {$in: names}}, callback);
};

/**
 * 根据登录名查找用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} loginName 登录名
 * @param {Function} callback 回调函数
 */
exports.getUserByLoginName = function (loginName, callback) {
    User.findOne({login_name: loginName}, callback);
};

/**
 * 根据登录名,密码查找用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} loginName 登录名
 * @param {String} password 密码
 * @param {Function} callback 回调函数
 */
exports.getUserByLoginNameAndPassword = function (loginName, password, callback) {
    User.findOne({login_name: loginName, password: password}, callback);
};

/**
 * 根据用户ID，查找用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} id 用户ID
 * @param {Function} callback 回调函数
 */
exports.getUserById = function (id, callback) {
    User.findOne({_id: id}, callback);
};

/**
 * 根据用户token，查找用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} token 用户token
 * @param {Function} callback 回调函数
 */
exports.getUserByToken = function (token, callback) {
    User.findOne({token: token}, callback);
};

/**
 * 根据用户ID列表，获取一组用户
 * Callback:
 * - err, 数据库异常
 * - users, 用户列表
 * @param {Array} ids 用户ID列表
 * @param {Function} callback 回调函数
 */
exports.getUsersByIds = function (ids, callback) {
    User.find({_id: {'$in': ids}}, callback);
};

/**
 * 根据关键字，获取一组用户
 * Callback:
 * - err, 数据库异常
 * - users, 用户列表
 * @param {String} query 关键字
 * @param {Object} opt 选项
 * @param {Function} callback 回调函数
 */
exports.getUsersByQuery = function (query, opt, callback) {
    User.find(query, '', opt, callback);
};

/**
 * 根据查询条件，获取一个用户
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {String} name 用户名
 * @param {String} key 激活码
 * @param {Function} callback 回调函数
 */
exports.getUserByNameAndKey = function (loginname, key, callback) {
    User.findOne({login_name: loginname, retrieve_key: key}, callback);
};

/**
 * 更新一个用户的数据
 * Callback:
 * - err, 数据库异常
 * @param {Object} conditions 更新条件
 * @param {Object} key 需要更新的内容
 * @param {Object} options 选择项
 * @param {Function} callback 回调函数
 */
exports.updateUser = function (conditions, update, options, callback) {
    User.update(conditions, update, options, callback);
};

/**
 * 更新一个用户的数据，并返回更新后的对象
 * Callback:
 * - err, 数据库异常
 * - user, 用户
 * @param {Object} conditions 更新条件
 * @param {Object} key 需要更新的内容
 * @param {Object} options 选择项
 * @param {Function} callback 回调函数
 */
exports.updateUserAndGetIt = function (conditions, update, options, callback) {
    User.findOneAndUpdate(conditions, update, options, callback);
};

exports.newAndSave = function (name, loginname, pass, isthirdpartylogin, callback) {
    var user = new User();
    user.nick_name = name;
    user.login_name = loginname;
    user.password = pass;
    user.isThirdPartyLogin = isthirdpartylogin;
    user.token = uuid.v4();
    user.save(callback);
};

exports.makeGravatar = function (email) {
    return 'http://www.gravatar.com/avatar/' + utility.md5(email.toLowerCase()) + '?size=48';
};

exports.getGravatar = function (user) {
    return user.avatar || makeGravatar(user);
};