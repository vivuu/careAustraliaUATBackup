import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import userLoginCtrl from '@salesforce/apex/LWR_LoginCTRL.userLoginCtrl';
import resendOTP from '@salesforce/apex/LWR_LoginCTRL.resendOTP';

export default class Lwr_loginCMP extends NavigationMixin(LightningElement) {
    @api forgotPasswordLabel;
    @api forgotPasswordPageURL;

    @api createAccountLabel;
    @api createAccountPageURL;

    @api resendOTPLabel;
    @api otpLength;

    @api returnURL;

    @track username = '';
    @track password = '';
    confirmOTP = '';

    @track loginNavURL = '';

    errorMsg = '';
    otp= '';
    @track hasError = false;

    @track otpScreen = false;

    @track cmpValidations = {};

    handleUsernameInput(event){
        console.log('username ',event.detail.value);
        let username = event.target.value;
        let usernameInput = this.template.querySelector('.username');
        if(username.trim() === ''){
            this.cmpValidations.hasOwnProperty('Username') ? (this.cmpValidations.Username = true) : (this.cmpValidations['Username'] = true) ;
            usernameInput.setCustomValidity('Username is Required');
        }else{
            this.cmpValidations.hasOwnProperty('Username') ? (this.cmpValidations.Username = false) : (this.cmpValidations['Username'] = false) ;
            this.username = event.detail.value;
            usernameInput.setCustomValidity('');
        }
        usernameInput.reportValidity();
    }
    handlePasswordInput(event){
        let password = event.target.value;
        console.log('password detail.vlaue',event.detail.value);
        let passwordInput = this.template.querySelector('.password');
    //    console.log('pass Inpu',passwordInput);
        if(password.trim() === ''){
            this.cmpValidations.hasOwnProperty('Password') ? (this.cmpValidations.Password = true) : (this.cmpValidations['Password'] = true) ;
            passwordInput.setCustomValidity('Password is required.');
        }else{
            this.password = event.target.value;
            this.cmpValidations.hasOwnProperty('Password') ? (this.cmpValidations.Password = false) : (this.cmpValidations['Password'] = false) ;
            passwordInput.setCustomValidity('');
        }
        passwordInput.reportValidity();
    }

    handleForgotPassword(){
        this.handleNavigation(this.forgotPasswordPageURL);
    }

    handleCreateAccountPassword(){
        this.handleNavigation(this.createAccountPageURL);
    }

    handleNavigation(pageURL){
        location.replace(pageURL);
        /*
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: pageURL
            }
        }); */
    }

    userLogin(){
        console.log('username ',this.username);
        console.log('password ',this.password);
        console.log('otpLength ',this.otpLength);
        console.log('return Url ',this.returnURL);
        var submitButton = this.template.querySelector('.submitbutton');
        let fieldErrorStr = '';
        let hasInputFieldError = false;
        for(const[key, value] of Object.entries(this.cmpValidations)){
            if(value === true){
                fieldErrorStr = fieldErrorStr+' '+ key;
                hasInputFieldError = true;
            }
        }
        if(hasInputFieldError){
           let setCustomMsg = 'You have errors on '+ fieldErrorStr + '. Please correct them before procceding.';
           submitButton.setCustomValidity(setCustomMsg);
           submitButton.reportValidity();
        }else{
            submitButton.setCustomValidity('');
            submitButton.reportValidity();
            this.errorMsg = '';
                userLoginCtrl({
                    username: this.username,
                    password: this.password,
                    otpLength: this.otpLength,
                    StartURL: this.returnURL
                }).then((response)=>{
                    console.log(response);
                    if(response.success === true){
                        this.otp = response.otpValue;
                        this.errorMsg = response.errorMsg;
                        this.loginNavURL = response.loginNavURL;
                        this.hasError = false;
                        this.otpScreen = true;
                    }else{
                        this.otpScreen = false;
                        this.otp = ''; 
                        this.hasError = true;
                        this.errorMsg = response.errorMsg;
                        this.loginNavURL = response.loginNavURL;
                    }
                }).catch((e)=>{
                    console.log(e);
                })
            }
    }

    handleOtpVerification(event){
        console.log('otp ',event.target.value);
        let otp = event.target.value;
        let otpInput = this.template.querySelector('.otp');
        if(otp.trim() === ''){
            this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = true) : (this.cmpValidations['OTP'] = true) ;
            otpInput.setCustomValidity('OTP is Required');
        }else{
            if(otp.length === this.otpLength){
                if(this.otp === otp){
                    this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = false) : (this.cmpValidations['OTP'] = false) ;
                    this.confirmOTP = event.detail.value;
                    otpInput.setCustomValidity('');
                }else{
                    this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = true) : (this.cmpValidations['OTP'] = true) ;
                    otpInput.setCustomValidity('OTP entered is incorrect.Please try again.');
                }
            }
        }
        otpInput.reportValidity();
    }

    VerifyOTP(){
        this.handleNavigation(this.returnURL);
    }

    resendOTP(){
        this.otp = '';
        this.otpValue = '';
        resendOTP({
            username: this.username,
            otpLenght: this.otpLength,
            LoginNavURL: this.loginNavURL
        }).then((response)=>{
            if(response.success === true){
                this.otp = response.otpValue;
                this.loginNavURL = response.loginNavURL;
                this.errorMsg = '';
                this.otpScreen = true;
                this.hasError = false;
            }else{
                this.otpScreen = true;
                this.otp = '';
                this.hasError = true;
                this.errorMsg = response.errorMsg;
                this.loginNavURL = response.loginNavURL;
            }
        }).catch((error)=>{
            console.log('resend otp error ',error);
        });
    }
}