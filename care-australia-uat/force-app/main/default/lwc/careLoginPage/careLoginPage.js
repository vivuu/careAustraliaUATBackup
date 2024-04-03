import { LightningElement, wire, track } from 'lwc';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Contact from '@salesforce/schema/Contact';
import Salutation from '@salesforce/schema/Contact.Salutation';
import { CurrentPageReference } from 'lightning/navigation';
import USER_ID from '@salesforce/user/Id';
import updateContact from '@salesforce/apex/CareCustomLoginCtrl.updateContact';
import getContactbyUserID from '@salesforce/apex/CareCustomLoginCtrl.getContactbyUserID';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LinkTCpdf from '@salesforce/resourceUrl/TermsandConditionsFile';
import LinktoPrivacyPolicy from '@salesforce/resourceUrl/PrivacyPolicyCA';
export default class CareLoginPage extends LightningElement {
    @track isCreateAnAccount = true;
    @track isSigninAccount = true;
    @track CartModules = false;
    isEmailValid = true;
    isPasswordValid = true;
    openTCpdfDoc = LinkTCpdf;
    openPrivPolicy=LinktoPrivacyPolicy;
    salutationValues;
    createContact = {};
    lendLogo = LendWithCareImages + '/yellowLogo.png';
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
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    @wire(CurrentPageReference)
    currentPageReference;
    connectedCallback() {
        const currentUrl = window.location.href;
        console.log('Current URL:', currentUrl);
        if( !currentUrl.includes('builder.salesforce-experience.com') && !currentUrl.includes('salesforce-experience.com') ){
            console.log('User ID:', USER_ID);
            getContactbyUserID({ userID: USER_ID }).then(result => {
                if (result) {
                    console.log('Contact details-->'+JSON.stringify(result));
                    this.contactId = result.Id;
                    if (result.Email) {
                        this.Email = result.Email;
                        this.emailAvailable = true;
                    }
                    if (result.LastName) {
                        this.Lastname = result.LastName;
                    }
                    if (result.FirstName) {
                        this.Firstname = result.FirstName;
                    }
                    if (result.Salutation) {
                        this.selectedValue = result.Salutation;
                    }
                    if (result.Birthdate) {
                        this.Birthdate = result.Birthdate;
                    }
                    if (result.MailingPostalCode) {
                        this.MailingPostalCode = result.MailingPostalCode;
                    }
                    if (result.MobilePhone) {
                        this.MobilePhone = result.MobilePhone;
                        this.MobileNumberAvailable = true;
                        console.log('Phone Sayan-->'+result.Phone);
                    }
                    if (this.Email && this.Lastname && this.Firstname && this.Birthdate && this.MailingPostalCode && this.MobilePhone) {
                        this.ValidToSave = true;
                    } else {
                        this.ValidToSave = false;
                    }
                    this.TermsAndCondition = result.Terms_and_conditions__c;
                    console.log('result:--> ' + result.MailingPostalCode);
                    if (result.Terms_and_conditions__c == true &&  this.ValidToSave) {
                        window.location.assign(currentUrl + 'caredashboard');
                    } else {
                        console.log('Inside-result');
                        console.log('Create an account-->'+this.isCreateAnAccount);
                        this.showTerm = true;
                    }
                } else {
                    window.location.assign(currentUrl + 'homepage');
                }

                console.log('result:--> ' + JSON.stringify(result));
            }).catch(error => {
                window.location.assign(currentUrl + 'homepage');
                this.showTerm = false;
                this.showToast('Error', JSON.stringify(error), 'error', 'dismissable');
                console.log('Erroccured:- ' + JSON.stringify(error));
            })
        }

    }

    handleClick() {
        this.isOpen = !this.isOpen;
    }

    closeModal() {
        this.CartModules = false;
        this.isCreateAnAccount = true;
    }
    openModal() {
        this.CartModules = true;
        this.isCreateAnAccount = false;
    }
    handleOptionClick(event) {
        const selectedValues = event.target.dataset.value;
        this.selectedValue = selectedValues;
        console.log('value-->' + this.selectedValue)
        this.createContact['Salutation'] = this.selectedValue;
        this.isOpen = false;
    }

    createAccount() {
        const currentUrl = window.location.href;
     /*   if (this.ValidToSave == true) {
            let customDateInput = this.template.querySelector('input[id="customDate"]');
            if (customDateInput) {
                this.ValidToSave = true;
            } else {
                this.ValidToSave = false;
                this.showToast('Error', 'Please enter Birthdate in correct format', 'error', 'dismissable');
            }
        }*/
        console.log('ValidToSave-->'+this.ValidToSave);
        if (this.ValidToSave) {
              let customDateInput = this.template.querySelector(".birthdate").value;
              console.log('customDateInput--> '+customDateInput)
              let customPhoneInput = this.template.querySelector(".Phone").value;
              console.log('customPhoneInput--> '+customPhoneInput)
            if (customDateInput && customPhoneInput) {
                 let checkboxValue = this.template.querySelector('.checkbox');
            console.log('checkboxValue--> ' + checkboxValue.checked)
            if (checkboxValue.checked) {
                this.createContact['Id'] = this.contactId;
                updateContact({ insertContact: this.createContact }).then(result => {
                    if (result != null) {
                        window.location.assign(currentUrl + 'homepage');
                    }
                    console.log('result:--> ' + result);
                }).catch(error => {
                    this.showToast('Error', error.message, 'error', 'dismissable');
                    console.log('Erroccured:- ' + error.message);
                })
            } else {
                this.showToast('Info', 'Please accept Terms of Use and Privacy Policy', 'info', 'dismissable');
            }
            } else {
                this.ValidToSave = false;
                this.showToast('Error', 'Please enter Birthdate in correct format', 'error', 'dismissable');
            }
        } else {
            this.showToast('Error', 'All required fields must be filled properly', 'error', 'dismissable');
        }


    }
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
            console.log(' this.salutationValues==>' + this.salutationValues);
        } else if (error) {
            this.salutationValues = undefined;
            console.log('error>' + error);
        }

    }
    handleInputChange(event) {
        if (event.target.name != '') {
            this.createContact[event.target.name] = event.target.value;
        }
        if (event.target.name === 'Email') {
            let emailInput = this.template.querySelector('.email');
            let emailValue = event.target.value;
            const emailRegex = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;

            if (emailValue.trim() === '') {
                this.ValidToSave = false;
                emailInput.setCustomValidity('Email cannot be empty.');
            } else if (emailValue.match(emailRegex)) {
                this.ValidToSave = true;
                emailInput.setCustomValidity('');
            } else {
                this.ValidToSave = false;
                emailInput.setCustomValidity('Please enter a valid Email.');
            }
            emailInput.reportValidity();
        }
        if (event.target.name === 'FirstName') {
            let firstnameInput = this.template.querySelector('.firstname');
            let firstnameValue = event.target.value;
            if (firstnameValue.trim() === '') {
                this.ValidToSave = false;
                firstnameInput.setCustomValidity('Firstname cannot be empty.');
            } else {
                this.ValidToSave = true;
                firstnameInput.setCustomValidity('');
            }
            firstnameInput.reportValidity();
        }
        if (event.target.name === 'LastName') {
            let lastnameInput = this.template.querySelector('.lastname');
            let lastnameValue = event.target.value;
            if (lastnameValue.trim() === '') {
                this.ValidToSave = false;
                lastnameInput.setCustomValidity('Lastname cannot be empty.');
            } else {
                this.ValidToSave = true;
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
                PostcodeInput.setCustomValidity('Postcode cannot be empty.');
            } else {
                if (PostcodeValue.match(/^\d{4,}$/)) {
                    this.ValidToSave = true;
                    this.MailingPostalCode = event.target.value;
                    PostcodeInput.setCustomValidity('');
                } else {
                    // Invalid input
                    PostcodeInput.setCustomValidity('Please enter at least 4 digits.');
                    
                }
                
                
            }
            PostcodeInput.reportValidity();
        }
        if (event.target.name === 'Birthdate') {

            const datePattern = /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/;
            let birthdateInput = this.template.querySelector('.birthdate');
            let birthdateValue = event.target.value;
            console.log('datePattern--> ' + event.target.value)
            if (birthdateValue.trim() === '') {
                this.ValidToSave = false;
                birthdateInput.setCustomValidity('Birthdate cannot be empty.');
            } else if (birthdateValue.match(datePattern)) {
                this.ValidToSave = true;
                this.Birthdate = event.target.value;
                birthdateInput.setCustomValidity('');
            } else if (birthdateValue == null) {
                this.ValidToSave = false;
                birthdateInput.setCustomValidity('Enter BirthDate in correct format');
            } else {
                this.ValidToSave = false;
                birthdateInput.setCustomValidity('Enter BirthDate in correct format');
            }
            console.log('Birthdate--> ' + this.Birthdate)
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
                PhoneInput.setCustomValidity('Phone cannot be empty.');
            } 
            
            else {
                if (phoneRegex.test(PhoneValue)) {
                    // Valid input
                    this.ValidToSave = true;
                    this.MobilePhone = event.target.value;
                    PhoneInput.setCustomValidity('');
                } else {
                    this.ValidToSave = false;
                    // Invalid input
                    PhoneInput.setCustomValidity('Phone number must start with +61 and have 9 digits after it.');
                }
                
                //PhoneInput.setCustomValidity('');
            }
            PhoneInput.reportValidity();
        }

        console.log('ValidToSave--> ' + this.ValidToSave)
        if (event.target.name == 'Terms_and_conditions__c') {
            if (event.target.checked) {
                this.createContact['Terms_and_conditions__c'] = true;
            }
            else {
                this.createContact['Terms_and_conditions__c'] = false;
            }
            console.log('  this.CartModules-->' + this.CartModules)
        }
    }
}