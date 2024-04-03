import { LightningElement, wire, track } from 'lwc';

import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
import Salutation from '@salesforce/schema/Contact.Salutation';

import LinkTCpdf from '@salesforce/resourceUrl/TermsandConditionsFile';
import LinktoPrivacyPolicy from '@salesforce/resourceUrl/PrivacyPolicyCA';

import registerLenderExtUser from '@salesforce/apex/LWR_SelfReg_Ctrl.registerLenderExtUser';
import checkEmail from '@salesforce/apex/LWR_SelfReg_Ctrl.checkEmail';

import { NavigationMixin } from 'lightning/navigation';


export default class Lwr_selfRegistration_cmp extends NavigationMixin(LightningElement) {

    @track spinner = false;

    @track isCreateAnAccount = true;
    @track isSigninAccount = true;
    @track CartModules = false;
    isEmailValid = true;
    isPasswordValid = true;
    openTCpdfDoc = LinkTCpdf;
    openPrivPolicy=LinktoPrivacyPolicy;
    salutationValues;
    createContact = {};
    @track selectedValue = '';
    @track isOpen = false;
    contactId;
    @track showTerm = false;
    Email = '';
    Lastname = '';
    Firstname = '';
    MailingPostalCode = '';
    Birthdate = '';
    MobilePhone = '';
    TermsAndCondition;
    ValidToSave;
    CreateAccount;
    emailAvailable = false;
    MobileNumberAvailable = false;

    password = '';
    confirmPassword = '';

    //Checking validation before creating the account
    @track cmpValidations = {   
                                "Email":true,
                                "FirstName":true,
                                "LastName":true,
                                "MailingPostalCode":true,
                                "Birthdate":true,
                                "MobilePhone":true,    
                                "Terms_and_conditions__c":true,
                                "Password":true,
                                "ConfirmPassword":true

                            };


    @track regErrors;
    @track hasRegEror;

    @wire(getObjectInfo, { objectApiName: Contact })
    objectInfo;
    @wire(getPicklistValues,
        {
            recordTypeId: '$objectInfo.data.defaultRecordTypeId',
            fieldApiName: Salutation
        }
    )
    SalutationPicklistValues({ data, error }) {

        if (data) {
            this.salutationValues = data.values;
         //   console.log(' this.salutationValues==>' + this.salutationValues);
        } else if (error) {
            this.salutationValues = undefined;
            console.log('error>' + error);
        }

    }

    //Adding Wopra Login/self reg code
    woopraSelfRegTracking() {        
        // For Login
       // woopra.track("login");
        
        // Or for Registration
        var name = (this.createContact.FirstName+ ' '+ this.createContact.LastName);
        window.woopra.identify({
            email: this.createContact.Email,
            name: name,
            type: "registration"
        });
        window.woopra.track("form_fill");
       // woopra.track("regrestration");
    }

    handleOptionClick(event) {
        const selectedValues = event.target.dataset.value;
        this.selectedValue = selectedValues;
       // console.log('value-->' + this.selectedValue)
        this.createContact['Salutation'] = this.selectedValue;
        this.isOpen = false;
    }

    handleClick() {
        this.isOpen = !this.isOpen;
    }

    handleInputChange(event) {
        if (event.target.name != '') {
            this.createContact[event.target.name] = event.target.value;
        }
        if (event.target.name === 'Email') {
            this.spinner = true;
            let emailInput = this.template.querySelector('.email');
            let emailValue = event.target.value;
            const emailRegex = /[@.].*[@.]/; // /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/; ()

            if (emailValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Email') ? (this.cmpValidations.Email = true) : (this.cmpValidations['Email'] = true) ;
                emailInput.setCustomValidity('Email cannot be empty.');
            } else if (emailValue.match(emailRegex)) {
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('Email') ? (this.cmpValidations.Email = false) : (this.cmpValidations['Email'] = false) ;
                emailInput.setCustomValidity('');
            } else {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Email') ? (this.cmpValidations.Email = true) : (this.cmpValidations['Email'] = true) ;
                emailInput.setCustomValidity('Please enter a valid Email.');
            }

            if(this.ValidToSave && emailValue.includes('@') && emailValue.includes('.')){
                setTimeout(()=>{
                    this.checkEmail();
                },3000);
            }
            emailInput.reportValidity();
            this.spinner = false;
        }
        if (event.target.name === 'FirstName') {
            let firstnameInput = this.template.querySelector('.firstname');
            let firstnameValue = event.target.value;
            if (firstnameValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('FirstName') ? (this.cmpValidations.FirstName = true) : (this.cmpValidations['FirstName'] = true) ;
                firstnameInput.setCustomValidity('Firstname cannot be empty.');
            } else {
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('FirstName') ? (this.cmpValidations.FirstName = false) : (this.cmpValidations['FirstName'] = false) ;
                firstnameInput.setCustomValidity('');
            }
            firstnameInput.reportValidity();
        }
        if (event.target.name === 'LastName') {
            let lastnameInput = this.template.querySelector('.lastname');
            let lastnameValue = event.target.value;
            if (lastnameValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('LastName') ? (this.cmpValidations.LastName = true) : (this.cmpValidations['LastName'] = true) ;
                lastnameInput.setCustomValidity('Lastname cannot be empty.');
            } else {
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('LastName') ? (this.cmpValidations.LastName = false) : (this.cmpValidations['LastName'] = false) ;
                lastnameInput.setCustomValidity('');
            }
            lastnameInput.reportValidity();
        }
        if (event.target.name === 'MailingPostalCode') {
            let inputValue = event.target.value;
            inputValue = inputValue.replace(/[^0-9+]/g, '');
            event.target.value = inputValue;
            let PostcodeInput = this.template.querySelector('.postcode');
            let PostcodeValue = event.target.value;
            if (PostcodeValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('MailingPostalCode') ? (this.cmpValidations.MailingPostalCode = true) : (this.cmpValidations['MailingPostalCode'] = true) ;
                PostcodeInput.setCustomValidity('Postcode cannot be empty.');
            } else {
                if (PostcodeValue.match(/^\d{4,}$/)) {
                    this.ValidToSave = true;
                    this.cmpValidations.hasOwnProperty('MailingPostalCode') ? (this.cmpValidations.MailingPostalCode = false) : (this.cmpValidations['MailingPostalCode'] = false) ;
                    this.MailingPostalCode = event.target.value;
                    PostcodeInput.setCustomValidity('');
                } else {
                    // Invalid input
                    this.cmpValidations.hasOwnProperty('MailingPostalCode') ? (this.cmpValidations.MailingPostalCode = true) : (this.cmpValidations['MailingPostalCode'] = true) ;
                    PostcodeInput.setCustomValidity('Please enter at least 4 digits.');
                    
                }
                
                
            }
            PostcodeInput.reportValidity();
        }
        if (event.target.name === 'Birthdate') {

            const datePattern = /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/;
            let birthdateInput = this.template.querySelector('.birthdate');
            let birthdateValue = event.target.value;
          //  console.log('datePattern--> ' + event.target.value)
            if (birthdateValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = true) : (this.cmpValidations['Birthdate'] = true) ;
                birthdateInput.setCustomValidity('Birthdate cannot be empty.');
            } else if (birthdateValue.match(datePattern)) {
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = false) : (this.cmpValidations['Birthdate'] = false) ;
                this.Birthdate = event.target.value;
                birthdateInput.setCustomValidity('');
            } else if (birthdateValue == null) {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = true) : (this.cmpValidations['Birthdate'] = true) ;
                birthdateInput.setCustomValidity('Enter BirthDate in correct format');
            } else {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = true) : (this.cmpValidations['Birthdate'] = true) ;
                birthdateInput.setCustomValidity('Enter BirthDate in correct format');
            }
            if(this.ValidToSave = true){
                var today = new Date();
                var birthDate = new Date(birthdateValue);
                var age = today.getFullYear() - birthDate.getFullYear();
                var m = today.getMonth() - birthDate.getMonth();
                if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                    age--;
                }
                if(age >= 18){
                    this.ValidToSave = true;
                    this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = false) : (this.cmpValidations['Birthdate'] = false) ;
                    birthdateInput.setCustomValidity('');
                }else{
                    this.ValidToSave = false;
                    this.cmpValidations.hasOwnProperty('Birthdate') ? (this.cmpValidations.Birthdate = true) : (this.cmpValidations['Birthdate'] = true) ;
                    birthdateInput.setCustomValidity('You should be 18+ to register.');
                }
            }
            
          //  console.log('Birthdate--> ' + this.Birthdate)
            birthdateInput.reportValidity();
        }

        if (event.target.name === 'MobilePhone') {
           let inputValue = event.target.value;
            inputValue = inputValue.replace(/[^0-9+]/g, '');
            event.target.value = inputValue;
            let PhoneInput = this.template.querySelector('.Phone');
            let PhoneValue = event.target.value;
            const phoneRegex = /^\+61\d{9}$/;
            if (PhoneValue.trim() === '') {
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('MobilePhone') ? (this.cmpValidations.MobilePhone = true) : (this.cmpValidations['MobilePhone'] = true) ;
                PhoneInput.setCustomValidity('Phone cannot be empty.');
            } 
            
            else {
                if (phoneRegex.test(PhoneValue)) {
                    // Valid input
                    this.ValidToSave = true;
                    this.cmpValidations.hasOwnProperty('MobilePhone') ? (this.cmpValidations.MobilePhone = false) : (this.cmpValidations['MobilePhone'] = false) ;
                    this.MobilePhone = event.target.value;
                    PhoneInput.setCustomValidity('');
                } else {
                    this.ValidToSave = false;
                    // Invalid input
                    this.cmpValidations.hasOwnProperty('MobilePhone') ? (this.cmpValidations.MobilePhone = true) : (this.cmpValidations['MobilePhone'] = true) ;
                    PhoneInput.setCustomValidity('Phone number must start with +61 and have 9 digits after it.');
                }
                
                //PhoneInput.setCustomValidity('');
            }
            PhoneInput.reportValidity();
        }

        //console.log('ValidToSave--> ' + this.ValidToSave)
        if (event.target.name == 'Terms_and_conditions__c') {
            if (event.target.checked) {
                this.createContact['Terms_and_conditions__c'] = true;
                this.cmpValidations.hasOwnProperty('Terms_and_conditions__c') ? (this.cmpValidations.Terms_and_conditions__c = false) : (this.cmpValidations['Terms_and_conditions__c'] = false) ;
            }
            else {
                this.createContact['Terms_and_conditions__c'] = false;
                this.cmpValidations.hasOwnProperty('Terms_and_conditions__c') ? (this.cmpValidations.Terms_and_conditions__c = true) : (this.cmpValidations['Terms_and_conditions__c'] = true) ;

            }
        }
        if(event.target.name === 'Password'){
            let password = event.target.value;
            const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~])[A-Za-z\d!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]{12,}$/;
            let passwordInput = this.template.querySelector('.Password');
           // console.log('pass Inpu',passwordInput);
            if(password.trim() === ''){
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Password') ? (this.cmpValidations.Password = true) : (this.cmpValidations['Password'] = true) ;
                passwordInput.setCustomValidity('Password is required.');
            }else{
                if(passwordRegex.test(password)){
                    this.ValidToSave = true;
                    this.cmpValidations.hasOwnProperty('Password') ? (this.cmpValidations.Password = false) : (this.cmpValidations['Password'] = false) ;
                    this.password = event.target.value;
                    passwordInput.setCustomValidity('');
                }else{
                    this.ValidToSave = false;
                    this.cmpValidations.hasOwnProperty('Password') ? (this.cmpValidations.Password = true) : (this.cmpValidations['Password'] = true) ;
                    passwordInput.setCustomValidity('Password must contains minimum 12 characters with at least one uppercase letter, one lowercase letter, one number and one special character !"#$%&()*+,-./:;<=>?@[\]^_`{|}~.');
                }
            }
            passwordInput.reportValidity();
        }

        if(event.target.name === 'ConfirmPassword'){
            let conPassWord = this.template.querySelector('.ConfirmPassword');
            if(this.password != event.target.value){
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('ConfirmPassword') ? (this.cmpValidations.ConfirmPassword = true) : (this.cmpValidations['ConfirmPassword'] = true) ;
                conPassWord.setCustomValidity('Password and confirm Password do not match');
            }else{
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('ConfirmPassword') ? (this.cmpValidations.ConfirmPassword = false) : (this.cmpValidations['ConfirmPassword'] = false) ;
                conPassWord.setCustomValidity('');
            }
            conPassWord.reportValidity();
        }
    }

    createAccount(){
       // console.log('cmpval',this.cmpValidations);
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
            this.regErrors = '';
            this.spinner = true;
            var hostPath = location.origin;
            registerLenderExtUser({
                title: this.createContact.Salutation,
                firstname: this.createContact.FirstName,
                lastname: this.createContact.LastName,
                email: this.createContact.Email,
                postalCode: this.createContact.MailingPostalCode,
                birthDay: this.createContact.Birthdate,
                phone: this.createContact.MobilePhone,
                TermsAccepted: this.createContact.Terms_and_conditions__c,
                password: this.createContact.Password,
                startURL: hostPath
           }).then((response)=>{
               if(response != null){
                  // console.log(response);
                   this.hasRegEror = !response.success;
                   if(response.success === true){
                        if(response.returnSTR.startsWith('https://')){
                            this.spinner = false;
                            try{
                                this.woopraSelfRegTracking();
                            }
                            catch(e){
                                console.log('Exception Woopra ',JSON.stringify(e));
                            }
                            location.href = response.returnSTR;
                        }
                   }else{
                        this.spinner = false;
                        this.regErrors = response.returnSTR;
                   }
                   
                   
               }
           }).catch((error)=>{
                this.spinner = false;
               console.log('error in creating user ', JSON.pasrse(JSON.stringify(error)));
           });
        }
    }

    checkEmail(){
        let emailInput = this.template.querySelector('.email');
        let emailValue = this.createContact.Email;
        this.spinner = true;
        checkEmail({
            email: emailValue
        }).then((response)=>{
            console.log('checkemail', response);
            this.spinner = false;
            if(response === true){
                this.ValidToSave = false;
                this.cmpValidations.hasOwnProperty('Email') ? (this.cmpValidations.Email = true) : (this.cmpValidations['Email'] = true) ;
                emailInput.setCustomValidity('This email already exists.Try with other emails.');
            }else{
                this.ValidToSave = true;
                this.cmpValidations.hasOwnProperty('Email') ? (this.cmpValidations.Email = false) : (this.cmpValidations['Email'] = false) ;
                emailInput.setCustomValidity('');
            }
            emailInput.reportValidity();
        }).catch((error)=>{
            this.spinner = false;
            console.log('error in check email', error);
        }); 
    }
}