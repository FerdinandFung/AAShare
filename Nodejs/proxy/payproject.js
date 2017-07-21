var models = require('../models');
var PayProject = models.PayProject;
var eventproxy = require('eventproxy');
var email = require('../common/email');

exports.update = function (projectid, projectname, payitems, paypersons, callback) {

    var ep2 = new eventproxy();
    ep2.after('generateShortUrl', 3, function(generateShortUrl){
        email.sendShortUrlErrorMail(generateShortUrl.toString());
    });

    var ep = new eventproxy();
    ep.tail('newPayProject', function(newPayProject){
        var shortUrl = generateShortUrl();

        PayProject.findOne({shortUrl: shortUrl}, function (err, payproject) {
            if (err) {
                callback(err);

            } else if (payproject === null) {

                newPayProject.shortUrl = generateShortUrl();
                newPayProject.save(callback);

            } else {
                ep.emit('newPayProject', newPayProject);
                ep2.emit('generateShortUrl', newPayProject.projectid);
            }
        });
    });

    PayProject.findOne({projectid: projectid}, function (err, payproject) {
        if (err) {
            callback(err);

        } else if (payproject === null) {
            var payproject = new PayProject();
            payproject.projectid = projectid;
            payproject.name = projectname;
            payproject.payitems = payitems;
            payproject.paypersons = paypersons;
            
            ep.emit('newPayProject', payproject);

        } else {
            payproject.payitems = payitems;
            payproject.paypersons = paypersons;
            payproject.update_at = Date.now();

            payproject.save(callback);
        }
    });
};

var generateShortUrl = function() {
    var charArray = ['xZtVcpin1JWYQRKsmrdz7UPIy4aOELT5bFBSjHDMwkevqou82gX3lCN9h60fAG',
                 'yYfPBjgWOE9CFqkA4VGupHNisRS0658JnmMb2dZlcTxorwL7haz31KQIvUDtXe',
                 'hl5Eifc7CeBtysk9K8YuoZR6Qxb1IWVXFvPrJwLgdNqTzAUMpDj2n0mH34aOSG',
                 'q8Jw9Q7BAvSdbfEti0e2KRXxDlhz46YLWc5UFkrPpmGgyInjCTuoOVHs3aMN1Z',
                 'zC8TuLtkZohN092DIOUsBavmbWfjcJrgH1QMdwVG67nSqxPylRi435AXFYKEpe',
                 'L3NKSylIEfsFqcDwuebm5ovpkZ6gQ1xWXa8dCOGAUTMBjPR270hJn4tzYVri9H'];

    var alias = '';
    for(var i = 0; i < charArray.length; ++i) {
        alias = charArray[i].charAt(Math.random() * 61) + alias;
    }

    return alias
};
