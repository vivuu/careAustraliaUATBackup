/**
 * @description       : 
 * @author            : SUMEDH WASNIK
 * @group             : GERENT
 * @last modified on  : 01-25-2024
 * @last modified by  : SUMEDH WASNIK
 * Modifications Log
 * Ver   Date         Author          Modification
 * 1.0   01-22-2024   SUMEDH WASNIK   Initial Version
**/
public with sharing class LWR_LoginCTRL {
    @AuraEnabled
    public static LoginStatus userLoginCtrl(String username, String password, Integer otpLength,String StartURL){
        System.debug('username '+username);
        System.debug('password '+password);
        System.debug('otpLength '+otpLength);
        System.debug('StartURL '+StartURL);
        LoginStatus logStat = new LoginStatus();
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            if(lgn != null){
                logStat.success = true;
                logStat.errorMsg = '';
                logStat.loginNavURL = lgn.getUrl();
                String otp = generateOTP(otpLength);
                logStat.otpValue =  otp;
                if(otp != null){
                    logStat.emailSend = sendOTPViaEmail(username, otp);
                }
            }
        }catch(Exception ex){
            logStat.success = false;
            logStat.errorMsg = String.valueOf(ex);
            logStat.otpValue = '';
            logStat.loginNavURL = '';
            logStat.emailSend = false;
        }
        return logStat;
    }

    @AuraEnabled
    public static LoginStatus resendOTP(Integer otpLength, String LoginNavURL){
        System.debug('otpLength '+otpLength);
        System.debug('LoginNavURL '+LoginNavURL);
        LoginStatus logStat = new LoginStatus();
        try{    
                String username = UserInfo.getUserEmail();
                logStat.success = true;
                logStat.errorMsg = '';
                logStat.loginNavURL = LoginNavURL;
                String otp = generateOTP(otpLength);
                logStat.otpValue =  otp;
                if(otp != null){
                    logStat.emailSend = sendOTPViaEmail(username, otp);
                }
        }catch(Exception ex){
            System.debug('ex '+ex);
            logStat.success = false;
            logStat.errorMsg = String.valueOf(ex);
            logStat.loginNavURL = LoginNavURL;
            logStat.otpValue = '';
            logStat.emailSend = false;
        }
        return logStat;
    }

    public static String generateOTP(Integer otpLength){
        String randomDigits = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        String otp = randomDigits.subString(0,otpLength);
        return otp;
    }

    public static Boolean sendOTPViaEmail(String username, String otp){
        Boolean emailSendStatus = false;
        EmailTemplate emailTemplate = [SELECT Id, Name, Body,HtmlValue, Subject, IsActive  
                                        FROM EmailTemplate 
                                        WHERE Name ='OTP Verification Email Template'];

        String htmlbody1 = emailTemplate.HtmlValue.replace('{Recipient.Name}', UserInfo.getFirstName()+' '+UserInfo.getLastName());
        String htmlbody2 = htmlbody1.replace('{OTPCode}',otp);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.toAddresses = new String[] { username, 'sumedh.wasnik@gerent.com','sumedh1wasnik@gmail.com' };
        email.setSubject(emailTemplate.Subject);
        email.setHtmlBody(htmlbody2);
        email.setReplyTo('info@care.org.au');
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {email};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            emailSendStatus = true;
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
            emailSendStatus = false;
        }
        return emailSendStatus;
    }

    public class LoginStatus{
        @AuraEnabled
        public Boolean success{get;set;}
        @AuraEnabled
        public Boolean emailSend{get;set;}
        @AuraEnabled
        public String  otpValue{get;set;}
        @AuraEnabled
        public String  errorMsg{get;set;} 
        @AuraEnabled
        public String loginNavURL{get;set;}                      
    }
    
}