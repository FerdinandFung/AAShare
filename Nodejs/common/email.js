var nodemailer = require('nodemailer');

let smtpConfig = {
    host: 'smtp-mail.outlook.com',
    port: 587,
    secure: false, // upgrade later with STARTTLS
    requireTLS: true,
    // secureConnection: false, // use SSL,
    auth: {
        user: 'dev.funpig@outlook.com',
        pass: 'devfunpig@1'
    }
    // ,tls:{
    //     ciphers:'SSLv3'
    // }
};

var mailOptions = {
        from: 'dev.funpig@outlook.com', // sender address
        to: 'dev.funpig@outlook.com', // list of receivers
        cc: 'funpig@hotmail.com',
        subject: '[aashare] feedback', // Subject line
        text: '', // plaintext body
        html: '' // html body
    };

// var transporter = nodemailer.createTransport({
//     service: 'Gmail',
//     auth: {
//         user: 'dev.funpig@outlook.com',
//         pass: 'devfunpig@'
//     }
// });

var sendFeedbackMail = function(content) {

	let transporter = nodemailer.createTransport(smtpConfig);

    mailOptions['subject'] = '[aashare] feedback';
    mailOptions['text'] = content;

    console.log('mailOptions');
	console.log(mailOptions);

	transporter.sendMail(mailOptions, function(error, info){
    	if(error){
        	console.log('email sent error :' + error);
    	}else{
        	console.log('email sent: ' + info.response);
    	}
    	transporter.close();
	});

}

var sendShortUrlErrorMail = function(content) {

    let transporter = nodemailer.createTransport(smtpConfig);

    mailOptions['subject'] = '[aashare] ShortUrl Error';
    mailOptions['text'] = content;

    console.log('mailOptions');
    console.log(mailOptions);

    transporter.sendMail(mailOptions, function(error, info){
        if(error){
            console.log('email sent error :' + error);
        }else{
            console.log('email sent: ' + info.response);
        }
        transporter.close();
    });

}

exports.sendFeedbackMail = sendFeedbackMail;
exports.sendShortUrlErrorMail = sendShortUrlErrorMail;