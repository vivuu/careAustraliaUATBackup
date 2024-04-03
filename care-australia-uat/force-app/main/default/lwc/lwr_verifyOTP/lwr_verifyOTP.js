import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import resendOTP from '@salesforce/apex/LWR_LoginCTRL.resendOTP';

export default class Lwr_verifyOTP extends NavigationMixin(LightningElement) {

    @api LoginNavURL;
    @api otpLength;
    @api resendOTPErrorMsg;
    @api logoutURL;
    @api resendOTPLabel;
    @api verifyOTPPagePath;

    buttondisabled = false;
    otpVerified = false;
    resendOTPCount = 0;
    errorMsg = '';
    hasError = '';
    otp = '';
    @track confirmOTP = '';
    cmpValidations = {};
    @track otpGetTime;
    @track resetTimer = false;
    @track Verifybuttondisabled = false;


    connectedCallback() {
        if(this.otp === ''){
            this.getOTP();
        }
        console.log('In connected Call Back');
        localStorage.setItem('OTPVerified',false);
        window.setInterval(this.validatePageNav,1);
        
    }

    validatePageNav(){
        console.log('val page nav');
        var currentAddress = location.href;
        console.log(currentAddress);
        console.log(currentAddress === this.verifyOTPPagePath);
        if(currentAddress != this.verifyOTPPagePath){
            console.log('localStorage.getItem ',localStorage.getItem('OTPVerified'));
            if(localStorage.getItem('OTPVerified') == false){
                console.log('Please verify OTP');
                window.alert('Please verify the OTP before navigating to other pages.');
            }
        }
    }

    handleOtpVerification(event){
        console.log('otp ',event.target.value);
        let otp = event.target.value;
        this.checkOTPValidation(otp);
    }

    checkOTPValidation(otp){
        var otpInput = this.template.querySelector('.otp');
        if(otp.trim() === ''){
            this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = true) : (this.cmpValidations['OTP'] = true) ;
            otpInput.setCustomValidity('OTP is Required');
        }else{
            if(otp.length === this.otpLength){
                if(this.otp === otp){
                    this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = false) : (this.cmpValidations['OTP'] = false) ;
                    this.confirmOTP = otp;
                    this.otpVerified = true;
                    localStorage.setItem('OTPVerified',true);
                    clearInterval(this.validatePageNav);
                    otpInput.setCustomValidity('');
                }else{
                    this.otpVerified = false;
                    localStorage.setItem('OTPVerified',false);
                    this.cmpValidations.hasOwnProperty('OTP') ? (this.cmpValidations.OTP = true) : (this.cmpValidations['OTP'] = true) ;
                    otpInput.setCustomValidity('OTP entered is incorrect.Please try again.');
                }
            }
        }
        otpInput.reportValidity();
    }

    VerifyOTP(){
       location.replace(this.LoginNavURL);
    }

    resendOTP(){
        this.otp = '';
        this.otpValue = '';
        ++this.resendOTPCount;
        if(this.resendOTPCount > 3){
            this.hasError = true;
            this.buttondisabled = true;
            this.Verifybuttondisabled = true;
            this.errorMsg = this.resendOTPErrorMsg;
            setTimeout(()=>{
                location.replace(this.logoutURL);
            },5000);
        }else{
            this.getOTP();
        }

    }

    getOTP(){
        resendOTP({
            otpLength: this.otpLength,
            LoginNavURL: this.LoginNavURL
        }).then((response)=>{
            if(response.success === true){
                this.otp = response.otpValue;
                this.errorMsg = '';
                this.otpScreen = true;
                this.hasError = false;
                this.checkOTPTime();
            }else{
                this.otpScreen = true;
                this.otp = '';
                this.hasError = true;
                this.errorMsg = response.errorMsg;
            }
        }).catch((error)=>{
            console.log('resend otp error ',JSON.stringify(error));
        });
    }

    checkOTPTime(){
        clearInterval(this.otpTimeCounter());
        this.otpGetTime = Date.now();
        console.log('set time ',this.otpGetTime);
        setInterval(this.otpTimeCounter, 10000);
    }

    otpTimeCounter(){
        var currentTime = Date.now();
            console.log('current Time ',currentTime);
            console.log('time difference ',currentTime - this.otpGetTime);
            if((currentTime - this.otpGetTime) >= 600000){
                this.hasError = true;
                this.Verifybuttondisabled = true;
                this.errorMsg = 'OTP time limit has been expired. Please try again.'
            }
    }
}