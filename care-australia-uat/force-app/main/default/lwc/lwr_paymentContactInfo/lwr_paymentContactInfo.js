import { LightningElement, wire, track, api } from 'lwc';
import getLenderBalance from '@salesforce/apex/LWC_AllLoansCtrl.getLenderBalance';
import updateContactPostalAndMobile from '@salesforce/apex/LWC_AllLoansCtrl.updateContactPostalAndMobile';
import LinkTCpdf from '@salesforce/resourceUrl/TermsandConditionsFile';
import LinktoPrivacyPolicy from '@salesforce/resourceUrl/PrivacyPolicyCA';
export default class Lwr_paymentContactInfo extends LightningElement {

    @api contactid
    noPostcode = true;
    noMobilePhone = true;
    noTermsAndCondition=true;
    @track newMobilePhone = '';
    @track newMailingPostCode = '';
    @track mobileErrorMsg = '';
    @track showMobileErrorMsg = false;
    @track postcodeErrorMsg = '';
    @track showPostcodeErrorMsg = false;
    isLoading=false;

    openTCpdfDoc = LinkTCpdf;
    openPrivPolicy=LinktoPrivacyPolicy;                   


    @wire(getLenderBalance, { conId: '$contactid' })
    wiredLenderBalance(lenderValue) {
        const { data, error } = lenderValue;
        if (data) {
            this.noMobilePhone = data.MobilePhone ? true : false;
            this.noPostcode = data.MailingPostalCode ? true : false;
            this.noTermsAndCondition=data.Terms_and_conditions__c ? true : false;
        } else if (error) {
            console.log('Error occured from getLenderBalance' + JSON.stringify(error));
        }
    }

    handleMobileChange(event) {
        this.newMobilePhone = event.target.value;
        if (!this.newMobilePhone) {
            this.mobileErrorMsg = 'Phone cannot be empty.';
            this.showMobileErrorMsg = true;
        } else if (!/^(\+61\d{9})$/.test(this.newMobilePhone)) {
            this.mobileErrorMsg = 'Phone number must start with +61 and have 9 digits after it.';
            this.showMobileErrorMsg = true;
        } else {
            this.mobileErrorMsg = '';
            this.showMobileErrorMsg = false;
        }
    }

    handlePostcodeChange(event) {
        this.newMailingPostCode = event.target.value;
        if (!this.newMailingPostCode) {
            this.postcodeErrorMsg = 'Postcode cannot be empty.';
            this.showPostcodeErrorMsg = true;
        } else if (this.newMailingPostCode.length < 4) {
            this.postcodeErrorMsg = 'Please enter at least 4 digits.';
            this.showPostcodeErrorMsg = true;
        } else {
            this.postcodeErrorMsg = '';
            this.showPostcodeErrorMsg = false;
        }
    }
    
    showTermsAndConditionErrorMsg=false
    termsAndConditionValue=false
    handleTermsAndConditionChange(event){
        this.termsAndConditionValue=event.target.checked;
        if( this.termsAndConditionValue){
            this.showTermsAndConditionErrorMsg=false;
        }else{
            this.showTermsAndConditionErrorMsg=true;
        }
    }

    gotoFifthPage() {
        // Perform all validations
        const isMobileValid = (this.noMobilePhone==false) ? this.validateMobile() : true;
        const isPostcodeValid = (this.noPostcode==false )? this.validatePostcode() : true;
        const isTermsValid = (this.noTermsAndCondition==false) ? this.validateTerms() : true;
    
        // If all validations pass, then proceed with updating contact
        if (isMobileValid && isPostcodeValid && isTermsValid) {
            this.handleUpdateContact();
        } else {
            // If any validation fails, do not proceed further
            console.log('Please fill in all required fields with valid values.');
        }
    
        // If all validations pass, then proceed with updating contact
        if (isMobileValid && isPostcodeValid && isTermsValid) {
            this.handleUpdateContact();
        }
        if(this.noMobilePhone==true && this.noPostcode==true && this.noTermsAndCondition==true  ){
            this.invokeEvent();
        }
    }
    
    validateMobile() {
        if (!this.newMobilePhone) {
            this.mobileErrorMsg = 'Phone cannot be empty.';
            this.showMobileErrorMsg = true;
            return false;
        } else if (!/^(\+61\d{9})$/.test(this.newMobilePhone)) {
            this.mobileErrorMsg = 'Phone number must start with +61 and have 9 digits after it.';
            this.showMobileErrorMsg = true;
            return false;
        } else {
            this.mobileErrorMsg = '';
            this.showMobileErrorMsg = false;
            return true;
        }
    }
    
    validatePostcode() {
        if (!this.newMailingPostCode) {
            this.postcodeErrorMsg = 'Postcode cannot be empty.';
            this.showPostcodeErrorMsg = true;
            return false;
        } else if (this.newMailingPostCode.length < 4) {
            this.postcodeErrorMsg = 'Please enter at least 4 digits.';
            this.showPostcodeErrorMsg = true;
            return false;
        } else {
            this.postcodeErrorMsg = '';
            this.showPostcodeErrorMsg = false;
            return true;
        }
    }
    
    validateTerms() {
        if (!this.termsAndConditionValue) {
            this.showTermsAndConditionErrorMsg = true;
            return false;
        } else {
            this.showTermsAndConditionErrorMsg = false;
            return true;
        }
    }
    
    handleUpdateContact() {
        this.isLoading=true;

        if (this.newMobilePhone || this.newMailingPostCode || this.termsAndConditionValue) {

            updateContactPostalAndMobile({
                contactId: this.contactid,
                mobilePhone: this.newMobilePhone,
                mailingPostalCode: this.newMailingPostCode,
                termsAndConditions: this.termsAndConditionValue
            })
                .then(result => {
                    console.log('Apex Result: ', result);
                    this.isLoading=false;
                    this.invokeEvent();

                })
                .catch(error => {
                    console.error('Apex Error: ', error);
                });
        }

        

    }

    invokeEvent(){
        this.dispatchEvent(new CustomEvent('fifthscreennavigation'));
    }
}