import { LightningElement, track, api, wire } from 'lwc';
import {Hamburger, MagGlass, UserIcons, ShoppingCart, LendWithCareImages, LWCLogo, UserSVG, FbIcon, GooIcon, AppIcon, AExpress, CC, VisaC, StripeC } from './careNavBarUtility';
import getLenderBalance from '@salesforce/apex/LWC_AllLoansCtrl.getLenderBalance';
import LWCConfigSettingMetadata from '@salesforce/apex/LWC_AllLoansCtrl.LWCConfigSettingMetadata';
import getLeastToCompleteLoanRecord from '@salesforce/apex/LWC_AllLoansCtrl.getLeastToCompleteLoanRecord';

import { 
    searchLoan,
    removeTransactionRecord,
    removeTransactionRecords,
    removeZeroAmountTransactionRecord,
    recurringRecordCreation,
    createTransactionRecord,
    updateTransactionRecord,
    updateTransactionRecords,
    createVDTransaction,
    isGuestUser,
    getCurrentUser,
    updateDonationRecord,
    TopupTransactionRecords,
    subscribe,
    createMessageContext,
    publish,
    CARTMC,
    getStripePaymentConfigs,
    processPaymentByCard,
    processPaymentByWallet,
    processRD,
    getAccesstoken,
    getContactForGuest,
    getPaypalPaymentLink,
    capturePayPalOrder,
    processPayPal,
    getAlert,
    getContent
} from './careNavBarUtility';
import {updateTransactionCostIfLenderBalanceEnabled, updateCartItemsLength, removeZeroAmountTransaction, updateTransactionCost } from './careNavBarUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// Define a debounce function
const debounce = (func, delay) => {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            func(...args);
        }, delay);
    };
};
export default class CareNavBar extends LightningElement {
    canDeleteLoanFromCart = true;
    isTopupOnly = false;
    MGlass = MagGlass;
    UseAvatar = UserIcons;
    shopcart = ShoppingCart;
    changeChampionWindowBody;
    nboxTitle;
    gotoContactUsPage() {
        window.location.assign('carecontactus');
    }
    //Paypal Starts here
    token;
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }
    paypalPButton;
    accesstoken;
    conId;
    paymentDetail = {};
    urlForPayment;
    @track showCoverTransactionCost = false; //Cover Transaction Cost
    @track coverTransactionCost=0; //Cover Transaction Cost
    ifPaypalPayment() {
        this.transactionIdsCommon();
        this.rdToken = {};
        this.paymentToken = {};
        this.createTokenForRd = false;
        this.cardPayment = false;
        // this.paypalPayment=true;
        this.googlePayment = false;
        this.payByMethod = 'Paypal';
        let vdAmount = Number(localStorage.getItem('vdAmount'));
        (!this.showCoverTransactionCost && vdAmount == 0 ) ? localStorage.setItem('zeroTransFlag',1) : localStorage.setItem('zeroTransFlag',0);
        this.setFourthPage();
        this.getAccessTokens();
        //  this.payableAmount();
    }
    getAccessTokens() {
        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 5000);
        getAccesstoken({})
            .then(result => {
                this.accesstoken = result;
                if (this.accesstoken != null) {
                    this.paypalPButton = true;
                } else {
                    this.paypalPButton = false;
                }
                console.log('accesstoken: ', this.accesstoken)
            })
            .catch(error => {
                console.log('Access token error: ', JSON.stringify(error))
            })
        if (this.isGuest == true) {
            getContactForGuest({})
                .then(result => {
                    this.conId = result.Id;
                })
                .catch(error => {
                    console.log('Guest contact error: ', JSON.stringify(error))
                })
        }
    }
    getPaymentLink() {
        this.canDeleteLoanFromCart =false;
        this.transactionIdsCommon();
        if(this.transactionIds.length > 0){
            this.isLoading = true;
            let currentUrl = window.location.href;
            let urlParts = currentUrl.split('/');
            let index = urlParts.indexOf('s');
            let desiredUrl;
            if (index !== -1) {
                desiredUrl = urlParts.slice(0, index + 1).join('/');
            } else {
                console.log('Segment not found in URL');
            }
            let successPageUrl = desiredUrl + '/careviewallloans?carecart=true&CartModules=true&OpenThankyouPageWithNavBar=true&accesstoken=' + this.accesstoken + '&usedLenderBalance=' + this.usedLenderBalance+'&email='+this.lenderEmail+'&name='+this.lenderName.replace(/\s/g, "_");
            let returnPageUrl = desiredUrl + '/careviewallloans?carecart=true&CartModules=true';
            if (this.contactid != null) {
                this.conId = this.contactid;
            }
            this.paymentDetail = {
                refid: this.conId,
                amount: this.processingAmount,
                accesstoken: this.accesstoken,
                successPageUrl: successPageUrl,
                returnPageUrl: returnPageUrl
            }
            console.log('paymentDetail: ' + JSON.stringify(this.paymentDetail));
            getPaypalPaymentLink({ payment: this.paymentDetail })
                .then(result => {
                    this.noItemsInCart = false;
                    this.isLoading = false;
                    if (result != null) {
                        this.urlForPayment = result;
                        window.location.assign(this.urlForPayment);
                    }
                    console.log('urlForPayment: ' + this.urlForPayment);
                })
                .catch(error => {
                    console.log('paymentDetail: ' + JSON.stringify(error));
                })
        }
        else{
            this.noItemsInCart = true;
        }
    }
    //Paypal ends here
    @api timerLoading = false;
    LenwithCareLogo = LWCLogo;
    showGuestError = false;
    guestFName = '';
    guestLName = '';
    guestEmail = '';
    termCheck = false;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track loginPage = false;
    violet = false;
    yellow = false;
    ham = Hamburger;
    UserSVG = UserSVG;
    showErrorMessage = false;
    cookieVal = [];
    isGuest = true;
    //care cart     
    @api loanidfromparent = [];
    @api carecart = false;
    @api cartmodules;
    step = 1;
    currentStep = "1";
    showSpinner;
    showFirstPage = true;
    showSecondPage = false;
    showThirdPage = false;
    Facebook = FbIcon;
    Google = GooIcon;
    Apple = AppIcon;
    AmericanExp = AExpress;
    CardCC = CC;
    CardVisa = VisaC;
    StripeCard = StripeC;
    firstPage = true;
    CartLendChangeChampion = false;
    CartChangeChampion = false;
    @api secondPage = false;
    @api thirdPage = false;
    @api fourthPage = false;
    @api fifthPage = false;
    createAccount = false;
    signIn = false;
    checkOutasGuest = false;
    cardPayment = false;
    paypalPayment = false;
    ThankYouAfterPayNow = false;
    CartModules = true;
    OpenThankyouPageWithNavBar = false;
    AvatarImg = LendWithCareImages + '/client1.png';
    @api apiLoanResults; // @api decorator to create a public property
    @track isOpen1 = false;
    @track searchTerm = '';
    @track loanResults;
    // for cart functionality
    testTotal = 0;
    supportOneMoreProject = false;
    BorrowerFirstName = '';
    missingAmount = 0;
    FundedAmount = 0;
    GoalAmount = 0;
    progress = 0;
    amountFromParent = "50";
    amountFromParent = "50";
    @api amounttocart;
    @track setTime = 0;
    @track timeDuration = 2700000;//2700000 
    @track timerInterval;
    defaultDonationPercentage;
    totalAmount = 0;
    selectedAmounts = {};
    totalCartAmount = 0;
    selectedPercentages = {};
    totalcomboamount = 0;
    otherPercentage = false;
    errorMessage = false;
    OpenCCRedirectMessage = false;
    donationDefaultValue = 0;
    @api contactid;// = '0039D00000SzulBQAR';
    amountLeftToFullyFunded;
    isAdded = false;
    idsToDelete = [];
    @api voluntaryDonation = false;
    voluntaryDonationClosed = false;
    amountZero = false;
    indexToRemove;
    @api LenderTopup = false;
    sClosed = false;
    errorMessageTopup = false;
    @track donationAmount = 0;
    @track topUpAmount = 0;
    @api changeChampionTemplate = false;
    rdData = {};
    RDid;
    errorOnRDAmount = false;
    otherRDAmount = false;
    leasttocompleteLoanId;
    leastToCompleteRecord = {};
    otherRDAmounts = 0;
    errorTransaction = false;
    errorMessageOnTransaction;
    lenderBalanceAmount;
    lenderBalanceAmountCart;
    remainingBalanceAmount = 0;
    withLenderBalanceOnlyTemplate = false;
    withLenderBalanceAndOthersTemplate = false;
    @track cart = [];
    noPostcode = true;
    noMobilePhone = true;
    usingLenderBalanceOnly = false;
    lenderEmail;
    lenderName;
    payByMethod = '';
    firstAmount;
    secondAmount;
    thirdAmount;
    topupTranId;
    subscription = null;
    context = createMessageContext();
    guestCheckout = false;
    isLoading = false;
    get amounttocart() {
        return (this.loanidfromparent != undefined && this.loanidfromparent.length > 0 ? (this.loanidfromparent.length + (this.voluntaryDonation == true ? 1 : 0)) : 0) +
            (this.changeChampionTemplate == true ? 1 : 0) +
            (this.LenderTopup == true ? 1 : 0);
    }
    get totalNoOfCartItems() {
        return updateCartItemsLength(this);
    }
    get AddedLenderTopup() {
        return this.topUpAmount ? this.topUpAmount : 0;
    }
    get AddedChangeChampionAmount() {
        return this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0;
    }
    get totalLoansAndDonation() {
        if (this.voluntaryDonationClosed == false) {
            let currentCartItemsTotalAmount = 0;
            if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
                currentCartItemsTotalAmount = this.loanidfromparent
                    .filter(record => typeof record.selectedAmount === 'number')
                    .reduce((total, item) => total + item.selectedAmount, 0);
            }
            let amt = (currentCartItemsTotalAmount * this.donationAmount) / 100;
            if(this.defaultDonationPercentage == 0){
                return 0;
            }
            return parseFloat(amt.toFixed(2));
        }
        else {
            return 0;
        }
    }
    get totalLoansOnly() {
        let currentCartItemsTotalAmount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            currentCartItemsTotalAmount = this.loanidfromparent
                .filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, item) => total + item.selectedAmount, 0);
        }
        let amt = currentCartItemsTotalAmount + this.voluntaryDonation==true? (Number(currentCartItemsTotalAmount * this.donationAmount) / 100 ):0+
            (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0) +
            (this.topUpAmount ? this.topUpAmount : 0);
        return parseFloat(amt.toFixed(2));
    }
    resetCartVisible() {
        const closecartpage = true;
        const sentFromNavBar = new CustomEvent('fromnavbar', { detail: closecartpage });
        this.dispatchEvent(sentFromNavBar);
    }
    closeErrorPopup() {
        this.errorTransaction = false;
        this.errorMessageOnTransaction = '';
    }
    CCother(event) {
        this.otherRDAmount = true;
        const selectedButton = event.target;
        const buttons = this.template.querySelectorAll('.voldonaButtons');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });
        selectedButton.classList.add('selected');
        localStorage.setItem('rdAmt', 0);
        this.calculateTotalSelectedAmount();
    }
    otherRDAmountChange(event) {
        if (event.target.value < 10) {
            this.errorOnRDAmount = true;
            this.errorOnRDAmountNull = true;
        }
        else {
            this.errorOnRDAmount = false;
            this.otherRDAmounts = event.target.value;
            this.errorOnRDAmountNull = false;
            this.subscribeCCCurrency(3, 'Other', this.otherRDAmounts);
            localStorage.setItem('SelectedCCAmount', this.otherRDAmounts);
            localStorage.setItem('rdAmt', 0);
            this.calculateTotalSelectedAmount();
            this.CCOtherAmount(this.otherRDAmounts);
        }
    }
    @api
    callChangeChampionFromParent(event) {
        if (event == this.firstAmount.replace('$', '')) {
            this.CC35(event);
        }
        else if (event == this.secondAmount.replace('$', '')) {
            this.CC45(event);
        }
        else if (event == this.thirdAmount.replace('$', '')) {
            this.CC65(event);
        }
    }
    CCOtherAmount(otherAmount) {
        this.rdData['npe03__Amount__c'] = Number(otherAmount);
        this.rdData['npe03__Contact__c'] = this.contactid;
        this.rdData['npsp__RecurringType__c'] = 'Open';
        this.rdData['PaymentMethod'] = 'Credit Card';
        this.rdData['CurrencyIsoCode'] = 'AUD';
        this.rdData['Payment_Gateway__c'] = 'Stripe';
        this.rdData['npsp__Day_of_Month__c'] = '16';
        this.rdData['npsp__PaymentMethod__c'] = 'Credit Card';
        this.showCreditCard = this.isshowCreditCard;;
        this.showPaypal = false;
        this.showApplePay = false;
        this.showGooglePay = false;
        this.rdAmount = otherAmount;
        this.errorOnRDAmountNull = false;
        localStorage.setItem('rdAmt', otherAmount);
        this.calculateTotalSelectedAmount();
        localStorage.setItem('isCC',true);
    }
    subscribeCCCurrency(idx, curr, otherAmt) {
        localStorage.setItem('SelectedCCIndex', idx);
        localStorage.setItem('isCC', true);
        localStorage.setItem('SelectedCCAmount', curr);
        var o = otherAmt != undefined ? true : false;
        localStorage.setItem('OtherChecked', o);
        const message2 = {
            messageToSend: 'BecomeChampionCurrChange',
            currentRecordId: idx,
            amountAddedToCart: curr
        };
        publish(this.context, CARTMC, message2);
        if (otherAmt != undefined) {
            const message3 = {
                messageToSend: 'BecomeChampionOtherCurrChange',
                currentRecordId: otherAmt
            };
            publish(this.context, CARTMC, message3);
        }
        const message = {
            messageToSend: 'BecomeChampionAddToCart'
        };
        publish(this.context, CARTMC, message);
    }
    CC35(event) {
        const selectedButton = event.target;
        const buttons = this.template.querySelectorAll('.voldonaButtons');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });
        selectedButton.classList.add('selected');
        this.otherRDAmount = false;
        this.otherRDAmounts = 0;
        this.errorOnRDAmount = false;
        this.rdData['npe03__Amount__c'] = this.firstAmount.replace('$', '');
        this.rdData['npe03__Contact__c'] = this.contactid;
        this.rdData['npsp__RecurringType__c'] = 'Open';
        this.rdData['PaymentMethod'] = 'Credit Card';
        this.rdData['CurrencyIsoCode'] = 'AUD';
        this.rdData['Payment_Gateway__c'] = 'Stripe';
        this.rdData['npsp__Day_of_Month__c'] = '16';
        this.rdData['npsp__PaymentMethod__c'] = 'Credit Card';
        this.showCreditCard = this.isshowCreditCard;;
        this.showPaypal = false;
        this.showApplePay = false;
        this.showGooglePay = false;
        try {
            var amt = this.rdData['npe03__Amount__c'] != undefined ? (Number)(this.rdData['npe03__Amount__c']) : 0;
            localStorage.setItem('rdAmt', amt);
            //this.rdAmount = (Number)(this.rdData['npe03__Amount__c']);
            this.subscribeCCCurrency(0, this.firstAmount);

        } catch (er) {
            console.log('eror from try catch rd ', er)
        }
        this.rdAmount = this.rdData['npe03__Amount__c'];
        this.errorOnRDAmountNull = false;
        this.calculateTotalSelectedAmount();
        localStorage.setItem('SelectedCCAmount',0);
        localStorage.setItem('isCC',true);
    }
    CC45(event) {
        const selectedButton = event.target;
        const buttons = this.template.querySelectorAll('.voldonaButtons');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });
        selectedButton.classList.add('selected');
        this.otherRDAmount = false;
        this.errorOnRDAmount = false;
        this.otherRDAmounts = 0;
        this.rdData['npe03__Amount__c'] = this.secondAmount.replace('$', '');
        this.rdData['npe03__Contact__c'] = this.contactid;
        this.rdData['npsp__RecurringType__c'] = 'Open';
        this.rdData['PaymentMethod'] = 'Credit Card';
        this.rdData['CurrencyIsoCode'] = 'AUD';
        this.rdData['Payment_Gateway__c'] = 'Stripe';
        this.rdData['npsp__Day_of_Month__c'] = '16';
        this.rdData['npsp__PaymentMethod__c'] = 'Credit Card';
        this.showCreditCard = this.isshowCreditCard;;
        this.showPaypal = false;
        this.showApplePay = false;
        this.showGooglePay = false;
        localStorage.setItem('rdAmt', this.rdData['npe03__Amount__c']);
        this.rdAmount = this.rdData['npe03__Amount__c'];
        this.errorOnRDAmountNull = false;
        this.subscribeCCCurrency(1, this.secondAmount);
        this.calculateTotalSelectedAmount();
        localStorage.setItem('SelectedCCAmount',0);
        localStorage.setItem('isCC',true);
    }
    CC65(event) {
        const selectedButton = event.target;
        const buttons = this.template.querySelectorAll('.voldonaButtons');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });
        selectedButton.classList.add('selected');
        this.otherRDAmount = false;
        this.errorOnRDAmount = false;
        this.otherRDAmounts = 0;
        this.rdData['npe03__Amount__c'] = this.thirdAmount.replace('$', '');
        this.rdData['npe03__Contact__c'] = this.contactid;
        this.rdData['npsp__RecurringType__c'] = 'Open';
        this.rdData['PaymentMethod'] = 'Credit Card';
        this.rdData['CurrencyIsoCode'] = 'AUD';
        this.rdData['Payment_Gateway__c'] = 'Stripe';
        this.rdData['npsp__Day_of_Month__c'] = '16';
        this.rdData['npsp__PaymentMethod__c'] = 'Credit Card';
        this.showCreditCard = this.isshowCreditCard;;
        this.showPaypal = false;
        this.showApplePay = false;
        this.showGooglePay = false;
        localStorage.setItem('rdAmt', this.rdData['npe03__Amount__c']);
        this.rdAmount = this.rdData['npe03__Amount__c'];
        this.errorOnRDAmountNull = false;
        this.subscribeCCCurrency(2, this.thirdAmount);
        this.calculateTotalSelectedAmount();
        localStorage.setItem('SelectedCCAmount',0);
        localStorage.setItem('isCC',true);
    }
    closeVoluntaryDonation() {
        localStorage.setItem('isVoluntary', false);
        localStorage.setItem('defaultDonationPercentage', null);
        //this.pageData['Id'] = '';
        localStorage.setItem('vdAmount', 0);
        this.voluntaryDonation = false;
        this.voluntaryDonationClosed = true;
        this.calculateTotalSelectedAmount();
        this.donationAmount =  0;
        this.testTotal = parseFloat(this.testTotal.toFixed(2));
        this.coverTransactionCost = this.testTotal * 0.03;
        this.showCoverTransactionCost = true;
        this.callUpdateDonationRecord();
    }
    removeEmptyTransaction(){
        if(this.pageData['Id'] != null && this.pageData['Id'] != '' && this.pageData['Id'] != undefined){
            removeZeroAmountTransaction(this);
        }
    }
    closeLenderTopup() {
        let transIds = [];
        if(this.LenderTopup && !this.voluntaryDonation && this.loanidfromparent.length == 0 && this.pageData['Id'] != null && this.pageData['Id'] != '' && this.pageData['Id'] != undefined){
            transIds.push(this.pageData['Id']);
        }
        if (this.TopupTransactionId != '' || this.TopupTransactionId != null || this.TopupTransactionId != undefined) {
            transIds.push(this.TopupTransactionId);
        }
        this.LenderTopup = false;
        this.LenderTopupClosed = false;
        this.calculateTotalSelectedAmount();
        this.topUpAmount = 0;
        this.topUpAmount1 = '$'+0;
        this.testTotal = parseFloat(this.testTotal.toFixed(2));
        if (transIds.length > 0 && this.TopupTransactionId != null) {
            removeTransactionRecords({ recordsToDelete: transIds })
                .then(result => {
                    if(this.pageData['Id'] != null && this.pageData['Id'] != '' && this.pageData['Id'] != undefined && transIds.includes(this.pageData['Id'])){
                        this.pageData = {};
                        localStorage.setItem('vdId', null);
                        localStorage.setItem('vdAmount', 0);
                        this.showCoverTransactionCost = false;
                    }
                    this.topupData = {};
                    this.TopupTransactionId = null;
                    localStorage.setItem('isTopup', false);
                    localStorage.setItem('TopupTransactionId', null);
                    localStorage.setItem('topupAmountfromStorage', 0);
                })
                .catch(error => {
                    console.log('error deleting bulky items ', JSON.stringify(error))
                })
        }
    }
    canContinue = false;
    topupData = {};
    errorMessageTopupNull = false;
    errorMessageTopupkKYCPending = false;
    TopupTransactionId;
    delayTimeout;
    topUpAmount1;
    tAmt=0;
    lenderTopupAmountChangesOn(event){
        let inputValue = event.target.value;
        inputValue = inputValue.replace(/\D/g, '');
        event.target.value = inputValue;
        this.topUpAmount1 = '$'+event.target.value;
        this.tAmt = Number(event.target.value);
    }
    lenderTopupAmountChanges() {
        console.log('lenderTopupAmountChanges');
        if (this.tAmt < 2) {
            this.errorMessageTopup = true;
            this.errorMessageTopupNull = false;
            this.errorMessageTopupkKYCPending = false;
            this.topUpAmount = Number(this.tAmt);
            this.calculateTotalSelectedAmount();
            this.canContinue = true;
        }
        else {
            this.errorMessageTopup = false;
            this.errorMessageTopupNull = false;
            this.errorMessageTopupkKYCPending = false;
            this.topUpAmount = Number(this.tAmt);
            this.calculateTotalSelectedAmount();
                this.topupData['Lender__c'] = this.contactid;
                this.topupData['Amount__c'] = this.topUpAmount;
                this.topupData['Type__c'] = 'Topup';
                this.TopupTransactionId = localStorage.getItem('TopupTransactionId');
                if ( (this.TopupTransactionId.length ==15 || this.TopupTransactionId.length ==18) && this.TopupTransactionId != null) {
                    this.topupData['Id'] = this.TopupTransactionId;
                }
                console.log('topupData : ',JSON.stringify(this.topupData));
                TopupTransactionRecords({ TopupRecord: this.topupData })
                    .then(result => {
                        if (result == null) {
                            this.errorMessageTopupNull = true;
                            this.errorMessageTopupkKYCPending = false;
                        }
                        else if (result == 'KYC Pending') {
                            this.errorMessageTopupkKYCPending = true;
                            this.errorMessageTopupNull = false;
                        }
                        else if (JSON.stringify(result).length >= 15 || JSON.stringify(result).length >= 18) {
                            this.TopupTransactionId = JSON.stringify(result);
                            this.TopupTransactionId = result;
                            this.topupData['Id'] = result;
                            localStorage.setItem('TopupTransactionId', this.TopupTransactionId);
                            localStorage.setItem('topupAmountfromStorage', this.topupData['Amount__c']);
                            localStorage.setItem('isTopup', true);
                            this.canContinue = false;
                        }
                    })
                    .catch(error => {
                        console.log('error topup ', JSON.stringify(error))
                    })
        }
    }
    pageData = {}
    addLeastAmountToTotal() {
        if (this.isAdded != true) {
            this.totalCartAmount = this.totalCartAmount + this.amountLeftToFullyFunded;
            this.FundedAmount = this.FundedAmount + this.amountLeftToFullyFunded;
            this.progress = (this.FundedAmount / this.GoalAmount) * 100;
            this.calculateTotalSelectedAmount();
            this.pageData['Amount__c'] = this.amountLeftToFullyFunded;
            this.pageData['Type__c'] = 'Loan';
            this.pageData['Loan__c'] = this.leasttocompleteLoanId;
            const currentPageData = [this.pageData];
            createTransactionRecord({ recordsToInsert: currentPageData })
                .then(result => {
                    this.pageData['TransactionId'] = result[0].Id;
                    if (result[0].Id.length >= 15 || result[0].Id.length >= 18) {
                        this.startTimer1();
                        this.isAdded = true;
                        this.supportOneMoreProject = false;
                        localStorage.setItem('isAdded', this.supportOneMoreProject);
                        this.leastToCompleteRecord = { ...this.leastToCompleteRecord, TransactionId: result[0].Id };
                        this.leastToCompleteRecord['selectedAmount'] = this.amountLeftToFullyFunded;
                        this.loanidfromparent = [...this.loanidfromparent, this.leastToCompleteRecord];
                        localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
                        localStorage.setItem('paymentArray', JSON.stringify(this.loanidfromparent));
                        this.calculateTotalSelectedAmount();
                    }
                })
                .catch(error => {

                    this.errorTransaction = true;
                    this.errorMessageOnTransaction = error.body.pageErrors[0].message;
                    this.FundedAmount = this.FundedAmount - this.amountLeftToFullyFunded;
                    this.progress = (this.FundedAmount / this.GoalAmount) * 100;
                })
        }
    }
    haveLenderBalance = false;
    isChampion=false;
    @wire(getLenderBalance, { conId: '$contactid' })
    wiredLenderBalance(lenderValue) {
        const { data, error } = lenderValue;
        if (data) {
            this.lenderBalanceAmount = data.Lender_Balance__c;
            this.lenderBalanceAmountCart = '$' + parseFloat(this.lenderBalanceAmount).toFixed(2);
            this.noMobilePhone = data.MobilePhone ? true : false;
            this.noPostcode = data.MailingPostalCode ? true : false;
            this.lenderEmail = data.Email ? data.Email : 0;
            this.lenderName = data.Name;
            this.isChampion = data.Champion__c;
            this.haveLenderBalance = data.Lender_Balance__c > 0 ? true : false;
            if (this.lenderBalanceAmount < 0) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
            }
        } else if (error) {
            console.log('Error occured from getLenderBalance' + JSON.stringify(error));
        }
    }
    @wire(getLeastToCompleteLoanRecord)
    wireddata(pageValue) {
        const { data, error } = pageValue;
        if (data) {
            this.leastToCompleteRecord = data;
            this.leasttocompleteLoanId = data.Id;
            this.BorrowerFirstName = data.Borrower__r ? data.Borrower__r.FirstName : '';
            this.missingAmount = data.Amount_Left_Before_Fully_Funded__c;
            this.FundedAmount = data.Amount_Funded__c;
            this.GoalAmount = data.Published_Amount_AUD__c != undefined ? Number(data.Published_Amount_AUD__c).toFixed(2) : data.Published_Amount_AUD__c;
            this.progress = (data.Amount_Funded__c / data.Published_Amount_AUD__c) * 100,
                this.amountLeftToFullyFunded = parseFloat(data.Amount_Left_Before_Fully_Funded__c.toFixed(2));
        } else if (error) {
            console.log('Error occured from least record' + JSON.stringify(error));
        }
    }
    @api calculateTotalSelectedAmount() {
        let amount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            amount = this.loanidfromparent.filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, record) => {
                    return total + record.selectedAmount;
                }, 0);
        }
        var isCC = localStorage.getItem('isCC')
        if (isCC == 'true' || isCC == true) {
            this.rdData['npe03__Amount__c'] = localStorage.getItem('rdAmt');
            this.rdData['npe03__Amount__c'] = this.rdData['npe03__Amount__c'].replace('$', '');
        }
        let defaultValue = localStorage.getItem('defaultDonationPercentage');
        this.defaultDonationPercentage = 15;
        this.defaultDonationPercentageValue = '15';
        if (defaultValue != null && defaultValue != 'null'
            && defaultValue != undefined && defaultValue != 'undefined') {
            this.defaultDonationPercentage = Number(defaultValue);
            this.defaultDonationPercentageValue = defaultValue;
                if (this.defaultDonationPercentage != '0' && this.defaultDonationPercentage != '10' 
                && this.defaultDonationPercentage != '15' && this.defaultDonationPercentage != '25') {
                    this.defaultDonationPercentageValue = 'Other';
                }
        }
        this.testTotal = parseFloat(amount.toFixed(2)) +
            (this.voluntaryDonation == true ? (parseFloat(amount.toFixed(2)) * Number(this.defaultDonationPercentage) / 100) : 0)
            + (this.LenderTopup == true ? Number(this.topUpAmount) : 0)
            + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0);
        this.testTotal = parseFloat(this.testTotal.toFixed(2));
        this.totalVDAmount = (parseFloat(amount.toFixed(2)) * Number(this.defaultDonationPercentage) / 100) 
    }
    @api calculateTotalAmount() {
        let currentCartItemsTotalAmount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            currentCartItemsTotalAmount = this.loanidfromparent
                .filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, item) => total + item.selectedAmount, 0);
        }
        this.testTotal = (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0) +
            currentCartItemsTotalAmount + this.topUpAmount +
            (currentCartItemsTotalAmount * this.donationAmount) / 100;
        this.testTotal = parseFloat(this.testTotal.toFixed(2));
    }
    renderedCallback() {
        if (!this.rendered) {
            if (this.signInCC) {
                var isCC = localStorage.getItem('isCC')
                if (isCC != undefined && isCC != 'undefined' && isCC != 'true') {
                    this.checkPreviousChangeChampion();
                }
            }
            if (localStorage.getItem('isCC') == 'true' && localStorage.getItem('isCC') == true
                ) {
                this.changeChampionTemplate = true;
                this.amounttocart = (this.loanidfromparent != undefined && this.loanidfromparent.length > 0 ? (this.loanidfromparent.length + (this.voluntaryDonation == true ? 1 : 0)) : 0) +
                    (this.changeChampionTemplate == true ? 1 : 0) +
                    (this.LenderTopup == true ? 1 : 0);
                this.rendered = true;
            }
            if (this.totalCartAmount > 0) {
                this.amountZero = false;
            }
            this.rendered = true;
        }
        const progressBarElements = this.template.querySelectorAll('.progressBarInner1');
        progressBarElements.forEach((progressBar) => {
            const progressValue = (progressBar.dataset.value >= 98.70) ? 99.00 : progressBar.dataset.value;
            progressBar.style.width = progressValue + "%";
            if (progressValue < 85) {
                progressBar.style.backgroundColor = "#FEBE10";
            } else {
                progressBar.style.backgroundColor = "#5C8F39";
            }
        });
        if (this.OpenThankyouPageWithNavBar && Number(localStorage.getItem("isGetResponseFromPaypal")) == 0) {
            this.isLoading = true;
            localStorage.setItem("isGetResponseFromPaypal" , 1);
        }
    }
    rendered = false;
    checkPreviousChangeChampion() {
        setTimeout(() => {
            if (localStorage.getItem('isCC') == 'true' || localStorage.getItem('isCC') == true) {
                this.changeChampionTemplate = true;
                var selIdx = localStorage.getItem('SelectedCCIndex');
                var isCC = localStorage.getItem('isCC');
                var selAmt = localStorage.getItem('SelectedCCAmount');
                this.otherRDAmount = localStorage.getItem('OtherChecked') == 'true';
                this.otherRDAmounts = selAmt;
                this.rdAmount = this.rdData['npe03__Amount__c'];
                if (selIdx != undefined) {
                    var ele = this.template.querySelectorAll('.voldonaButtons');
                    for (var e of ele) {
                        e.classList.remove('selected');
                    }
                    if (selIdx != undefined && ele != undefined) {
                        if (ele.length > selIdx) {
                            var element = ele[selIdx];
                            element.classList.add('selected');
                        }
                    }
                }
                var ele = this.template.querySelectorAll('.voldonaButtons');
                if (ele != undefined && ele.length > 0) {
                    this.rendered = false;
                    this.signInCC = false;
                }
            } else {
                this.changeChampionTemplate = false;
            }

        }, 0);
    }
    CloseCCRedirectMessage() {
        this.OpenCCRedirectMessage = false;
    }
    ok() {
        this.changeChampionTemplate = true;
        this.OpenCCRedirectMessage = false;
        this.secondPage = true;
        this.currentStep = "2";
        this.errorOnRDAmountNull = true;
    }
    cancel() {
        this.OpenCCRedirectMessage = false;
        this.secondPage = false;
        this.checkOutasGuest = false;
        this.createAccount = false;
        this.signIn = false;
        this.thirdPage = true;
        this.currentStep = "3";
        this.firstPage = false;
    }
    publishMC(loanId) {
        const message = {
            messageToSend: 'NavBar',
            currentRecordId: loanId
        };
        publish(this.context, CARTMC, message);
    }
    removeCurrentLoan(event) {
        this.indexToRemove = Number(event.target.dataset.id);
        const deleteFromParentComponent = new CustomEvent('delete', {
            detail: {
                TransactionId: this.loanidfromparent[this.indexToRemove].TransactionId,
                selectedAmount: this.loanidfromparent[this.indexToRemove].selectedAmount,
                Id: this.loanidfromparent[this.indexToRemove].Id,
            }
        });
        this.dispatchEvent(deleteFromParentComponent);
        var lId = this.loanidfromparent[this.indexToRemove].Id;
        if (this.loanidfromparent[this.indexToRemove].TransactionId != undefined) {
            removeTransactionRecord({ idToRemove: this.loanidfromparent[this.indexToRemove].TransactionId })
                .then(result => {
                    console.log('REM1164:', this.changeChampionTemplate);
                })
                .catch(error => {
                    console.log('error while deleting ', JSON.stringify(error))
                })
        }
        if (!isNaN(this.indexToRemove)) {
            if (this.loanidfromparent != undefined && this.indexToRemove >= 0 && this.indexToRemove < this.loanidfromparent.length) {
                this.loanidfromparent = this.loanidfromparent.filter((item, index) => index !== this.indexToRemove); // Remove 1 element at the specified index
                localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
                localStorage.setItem('paymentArray', JSON.stringify(this.loanidfromparent));
                if (this.loanidfromparent.length == 0) {
                    //this.stopTimer();
                    this.timerLoading = false;
                    removeTransactionRecord({ idToRemove: this.pageData['Id'] })
                    .then(result => {
                        this.voluntaryDonation = false;
                        localStorage.setItem('isVoluntary', false);
                        localStorage.setItem('timerLoading', false);
                        localStorage.setItem('vdId', null);
                        localStorage.setItem('vdAmount', 0);
                        this.pageData['Id'] = null;
                        localStorage.setItem('vdId',null);
                    })
                    .catch(error => {
                        console.log('error while deleting ', JSON.stringify(error))
                    })
                    
                }
                
                this.publishMC(lId);
                //this.createDonationTransRecord();
                if (this.loanidfromparent.length == 0) {
                    this.timerLoading = false;}
            }
        }
    }
    updateData = {};
    cartIndex;
    handleChangeSelect(event) {
        const itemId = this.loanidfromparent[event.target.dataset.id].TransactionId;
        this.cartIndex = this.loanidfromparent.findIndex(item => item.TransactionId === itemId);
        this.updateData['Amount__c'] = Number(event.target.value);
        this.updateData['Id'] = itemId;
        updateTransactionRecord({ rec: this.updateData })
            .then(result => {
                this.loanidfromparent = this.loanidfromparent.map((loan, index) => {
                    if (index === this.cartIndex) {
                        return {
                            ...loan,
                            OldFunded:loan.Funded__c,
                            Funded: loan.Funded__c + result.Amount__c,
                            Funded__c :result.Amount__c, 
                            selectedAmount: result.Amount__c,
                            progressBar: ((loan.Funded__c + result.Amount__c) /loan.Published_Amount_AUD__c)*100,
                            fundingOptions: loan.fundingOptions.map(option => ({
                                ...option,
                                selected: option.value == Number(result.Amount__c),
                            })),
                        };
                    }
                    return loan;
                });
                localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
                localStorage.setItem('paymentArray', JSON.stringify(this.loanidfromparent));
                this.calculateTotalSelectedAmount();
                this.createDonationTransRecord();
            })
            .catch(error => {
                console.log('error updating transaction recd ', JSON.stringify(error))
                this.errorTransaction = true;
                this.errorMessageOnTransaction = error.body.pageErrors[0].message;
            })
    }
    pageData = {};
    totalVDAmount = 0;
    defaultDonationPercentageValue = '15';
    VoluntaryDonationChange(event) {
        this.errorMessage = false;
        let val = event.target.value;
        if (val != 'Other' && Number(val) >= 0) {
            this.otherPercentage = false;
            this.otherPercentageValue = 0;
            this.defaultDonationPercentageValue = event.detail.value;
            this.defaultDonationPercentage = Number(event.detail.value);
            console.log('defaultDonationPercentageValue 947 : ',this.defaultDonationPercentageValue);
            console.log('defaultDonationPercentage : ',this.defaultDonationPercentage);
            localStorage.setItem('defaultDonationPercentage', this.defaultDonationPercentage);
            this.donationAmount = Number(event.detail.value);
            this.createDonationTransRecord();
        }
        else if (val == 'Other') {
            this.otherPercentage = true;
            this.otherPercentageValue = 0;
            this.defaultDonationPercentageValue = val;
            this.defaultDonationPercentage = 0;
            localStorage.setItem('defaultDonationPercentage', this.defaultDonationPercentage);
            this.donationAmount = 0;
            this.createDonationTransRecord();   
            let amt = this.loanAndRdAmount;
        }
    }
    vdAmount;
   @api createDonationTransRecord() {
        //this.showCoverTransactionCost=false;
        localStorage.setItem('vdAmount', 0);
        this.defaultDonationPercentage = '15';
        let defaultValue = localStorage.getItem('defaultDonationPercentage');
        if (defaultValue != null && defaultValue != 'null'
            && defaultValue != undefined && defaultValue != 'undefined') {
            this.defaultDonationPercentage = Number(defaultValue);
        }
        let currentCartItemsTotalAmount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            currentCartItemsTotalAmount = this.loanidfromparent
                .filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, item) => total + item.selectedAmount, 0);

        }
        if (this.contactid != null || this.contactid != undefined) {
            this.pageData['Lender__c'] = this.contactid;
        }
        if (this.pageData['Id'] != '' && this.pageData['Id'] != null &&
            this.pageData['Id'] != undefined && this.pageData['Id'] != 'null') {
            this.pageData['Id'] = this.pageData['Id'];
        }
        let voluntaryDonationAmt = ((currentCartItemsTotalAmount) * Number(this.defaultDonationPercentage) / 100);
        this.pageData['Lender__c'] = this.contactid;
        this.pageData['Amount__c'] = parseFloat(Number(voluntaryDonationAmt).toFixed(2));
        //this.pageData['Amount__c'] = this.showCoverTransactionCost ? parseFloat((((voluntaryDonationAmt+(currentCartItemsTotalAmount))*0.03) + voluntaryDonationAmt).toFixed(2)):  voluntaryDonationAmt;
        this.pageData['Type__c'] = 'Donation';

        if (this.pageData['Amount__c'] >= 0 && this.voluntaryDonation == true) {
            createVDTransaction({ rec: this.pageData })
                .then(result => {
                    if (result.Id.length >= 15 || result.Id.length >= 18) {
                        localStorage.setItem('vdId', result.Id);
                        this.pageData['Id'] = result.Id;
                        this.vdAmount = result.Amount__c;
                        localStorage.setItem('vdAmount', Number(this.vdAmount));
                        this.calculateTotalSelectedAmount();
                        if(this.pageData['Amount__c'] == 0){
                            this.showCoverTransactionCost = true;
                        }
                        if(this.showCoverTransactionCost || this.lenderBalanceSelected){          
                            if(this.lenderBalanceSelected){
                                this.coverTransactionCost = parseFloat(( ((Number(voluntaryDonationAmt) + Number(currentCartItemsTotalAmount)) - Number(this.lenderBalanceAmount)) * 0.03).toFixed(2));
                            }else{
                                this.coverTransactionCost = parseFloat(((Number(voluntaryDonationAmt) + Number(currentCartItemsTotalAmount)) * 0.03).toFixed(2));
                            }
                        }
                        else{
                            this.coverTransactionCost = parseFloat(((Number(voluntaryDonationAmt) + Number(currentCartItemsTotalAmount)) * 0.03).toFixed(2));
                        }
                        this.callUpdateDonationRecord(); // update record
                    }
                })
                .catch(error => {
                    console.log('error creating voluntary donation transaction record ', JSON.stringify(error));
                    localStorage.setItem('vdId', null);
                    this.pageData['Id'] = null;
                })
        }
        this.calculateTotalSelectedAmount();
    }

    endsWith5Or0(number) {
        return number % 10 === 0 || number % 10 === 5;
    }
    otherPercentageValue;
    otherPercentageChangeOn(event){
        this.otherPercentageValue = Number(event.target.value);
        this.donationAmount = Number(event.target.value);
        this.defaultDonationPercentage = Number(event.target.value);
        localStorage.setItem('defaultDonationPercentage', this.defaultDonationPercentage)
        this.defaultDonationPercentageValue = 'Other';
        clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                    this.otherPercentageChange();
            }, 1500);
    }
    otherPercentageChange(event) {
        
        if (this.otherPercentageValue > 0 && this.otherPercentageValue <=100) {
            this.errorMessage = false;
            //clearTimeout(this.delayTimeout);
            //this.delayTimeout = setTimeout(() => {
                this.createDonationTransRecord();
            //}, 3000);
        } else {
            this.errorMessage = true;
            let currentCartItemsTotalAmount = 0;
            if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
                currentCartItemsTotalAmount = this.loanidfromparent
                    .filter(record => typeof record.selectedAmount === 'number')
                    .reduce((total, item) => total + item.selectedAmount, 0);

            }
            this.testTotal = currentCartItemsTotalAmount + (currentCartItemsTotalAmount * 0) / 100
                + this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0);
            this.testTotal = parseFloat(this.testTotal.toFixed(2));

            if (this.pageData['Id'] != null) {
                removeTransactionRecord({ idToRemove: this.pageData['Id'] })
                    .then(result => {
                        this.pageData['Id'] = null;
                        this.vdAmount=0;
                        this.calculateTotalSelectedAmount();
                    })
                    .catch(error => {
                        console.log('error while deleting vd otherPercentageChange ', JSON.stringify(error))
                    })
            }
        }
    }
    @wire(LWCConfigSettingMetadata)
    wiredDataOfLWCConfigSettingMetadata({ error, data }) {
        if (data) {
            this.defaultDonationPercentage = (data.Default_Donation_at_Checkout__c).toString();
            this.donationAmount = this.defaultDonationPercentage;

            if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0 && this.donationAmount > 0) {
                this.calculateTotalSelectedAmount();
            }
            const currencies = data.Change_Champion_Currencies__c.split(',');
            this.firstAmount = currencies[0];
            this.secondAmount = currencies[1];
            this.thirdAmount = currencies[2];
        } else if (error) {
            console.error('Error:LWCConfigSettingMetadata ', error);
        }
    }
    get arrowIcon() {
        return this.isOpen1 ? '∧' : '∨';
    }
    toggleSection() {
        this.isOpen1 = !this.isOpen1;
    }
    handleInputChange(event) {
        this.searchTermRaw = event.target.value;
        this.searchTerm = this.searchTermRaw.toLowerCase();
        if (this.searchTerm) {
            this.showErrorMessage = false;
        }
    }
    handleKeyUp(event) {
        if (event.keyCode === 13) {
            this.searchLoans();
        }
    }

    searchLoans() {
        if (!this.searchTerm) {
            this.apiLoanResults = null;
            this.showErrorMessage = true; // Clear the results when the search term is empty
            return;
        }
        searchLoan({ searchKey: this.searchTerm })
            .then(result => {
                this.apiLoanResults = result;
                if (this.apiLoanResults) {
                    window.location.assign('-caresearchresults?searchTerm=' + this.searchTerm);
                } else {
                    console.log('No Data has been fetched');
                }
            })
            .catch(error => {
                console.log(error);
            });
    }
    @api openCartPage() {
        this.carecart = true;
        this.checkGuestUser();
        this.overflowFalse();
    }
    @api openCartPageFromAllLoansPage() {
        this.carecart = true;
        this.checkGuestUser();
        this.overflowFalse();
    }
    closeCartPage() {
        this.payButtonDisabled = false;

        this.noItemsInCart = false;
        this.paymentToken = {};
        this.rdToken = {};
        this.createTokenForRd = false;
        this.cardPayment = false;
        this.paypalPayment = false;
        this.googlePayment = false;
        this.setPaymentMethods();
        this.canDeleteLoanFromCart =false;
        this.processingAmount = (parseFloat(this.testTotal).toFixed(2) - (this.lenderBalanceSelected ? this.lenderBalanceAmount : 0)) + (this.showCoverTransactionCost? this.coverTransactionCost : 0) ;
        if (this.currentStep == "2") {
            if (this.isGuest) {
                this.currentStep = "1";
                this.firstPage = true;
                this.secondPage = false;
                this.checkOutasGuest = false;
                this.guestCheckout = true;
            }
            if (!this.isGuest) {
                this.firstPage = true;
                this.secondPage = false;
                this.currentStep = "1";
                this.checkOutasGuest = false;

                this.carecart = false;
                this.OpenCCRedirectMessage = false;
                this.secondPage = false;
                this.currentStep = "1";
                this.CartLendChangeChampion = false;
                this.CartChangeChampion = false;
                this.thirdPage = false;
                this.fourthPage = false
                this.fifthPage = false;
                this.firstPage = true;
                this.overflowTrue();
                this.resetCartVisible();
            }
            this.OpenCCRedirectMessage = false;
            this.secondPage = false;
            this.CartLendChangeChampion = false;
            this.CartChangeChampion = false;
        }
        else if (this.currentStep == "3") {
            this.OpenCCRedirectMessage = false;
            //this.createAccount=true;
            this.currentStep = "2";
            this.firstPage = false;
            this.secondPage = true;
            this.checkOutasGuest = false;
            this.guestCheckout = false;
            this.CartLendChangeChampion = false;
            this.CartChangeChampion = false;
            this.thirdPage = false;
            this.isRemainingBalance = false;
            this.checkPreviousChangeChampion();
            this.isLoading = false;
        }
        else if (this.currentStep == "4") {
            if(this.showGooglePay) {
                this.isLoading = true;
                this.payableFinalTransactionAmount();
            }

            this.thirdPage = true;
            this.fourthPage = false;
            this.currentStep = "3";
            this.LenderbalanceChecked = false;
            this.isLoading = false;
        }
        else if (this.currentStep == "5") {
            if (this.noMobilePhone && this.noPostcode) {
                if(this.showGooglePay) {
                    this.isLoading = true;
                    this.payableFinalTransactionAmount();
                }

                this.thirdPage = true;
                this.fourthPage = false
                this.currentStep = "3";
                this.fifthPage = false;
                this.LenderbalanceChecked = false;
                this.isLoading = false;
            }
            else {
                this.fourthPage = true;
                this.currentStep = "4";
                this.fifthPage = false;
                this.isLoading = false;
                this.thirdPage = false;
            }
            

        }
        else {
            this.carecart = false;
            this.OpenCCRedirectMessage = false;
            this.secondPage = false;
            this.currentStep = "1";
            this.CartLendChangeChampion = false;
            this.CartChangeChampion = false;
            this.thirdPage = false;
            this.fourthPage = false
            this.fifthPage = false;
            this.firstPage = true;
            this.overflowTrue();
            this.resetCartVisible();
        }
    }
    overflowTrue() {
        const overflow = true;
        const sentFromNavBar = new CustomEvent('fromnavbar', { detail: overflow });
        this.dispatchEvent(sentFromNavBar);
    }
    overflowFalse() {
        const overflow = false;
        const sentFromNavBar = new CustomEvent('fromnavbar', { detail: overflow });
        this.dispatchEvent(sentFromNavBar);
    }
    OpenDashboardPage() {
        let currentUrl = window.location.href;
        let urlParts = currentUrl.split('/');
        let index = urlParts.indexOf('s');
        let desiredUrl;
        if (index !== -1) {
            desiredUrl = urlParts.slice(0, index + 1).join('/');
        } else {
            console.log('Segment not found in URL');
        }
        window.location.assign(desiredUrl+'/caredashboard');
    }
    OpenHomePage() {
        window.location.assign('carebecomechangechampion');
    }
    handleCheckoutGuest() {
        this.guestCheckout = true;
        this.checkOutasGuest = false;
        var isCC = localStorage.getItem('isCC')
        if (isCC != undefined && isCC != 'undefined') {
            this.checkPreviousChangeChampion();
        }
    }
    handleCheckoutBack() {
        this.guestCheckout = false;
        this.checkOutasGuest = true;
    }

    handleStripePay(event) {
        this.rdToken = {};
        this.paymentToken = {};
        this.createTokenForRd = false;
        this.cardPayment = false;
        this.paypalPayment = false;
        this.googlePayment = true;

        this.payByMethod = 'GooglePay';

        this.paymentToken = event.detail;
        this.setFourthPage();
    }
    paymentError = '';
    transactionIds = [];
    finalTransactionAmount = 0;
    usedLenderBalance = 0;
    transactionIdsCommon() {
        this.transactionIds = [];
        var myA = localStorage.getItem('myArray');
        if (myA != undefined && myA != '' && myA != 'undefined') {
            this.storedArray = JSON.parse(localStorage.getItem('myArray'));
        }
        if (this.storedArray) {
            this.loanidfromparent = this.storedArray;
        }
        if (this.loanidfromparent.length > 0) {
            for (const item of this.loanidfromparent) {
                if (item.TransactionId != undefined) {
                    this.transactionIds.push(item.TransactionId);
                }
            }
            if (this.pageData['Id'] && this.pageData['Id'] != null && this.pageData['Id'] != 'null') {
                this.transactionIds.push(this.pageData['Id']);
            }
        }
        if (this.TopupTransactionId && this.TopupTransactionId !== null && this.TopupTransactionId !== 'null') {
            this.transactionIds.push(this.TopupTransactionId);
        }
        if (this.LenderTopup && this.tAmt > 0 && this.pageData['Id'] != null && this.showCoverTransactionCost) {
            this.transactionIds.push(this.pageData['Id']);
        }
        localStorage.setItem('transactionIds', this.transactionIds);
    }
    payableFinalTransactionAmount() {
        this.finalTransactionAmount = this.loanAndRdAmount + this.topUpAmount;
        this.usedLenderBalance = 0;
        if (this.lenderBalanceSelected) {
            if (this.topUpAmount > 0) {
                if (this.lenderBalanceAmount > this.loanAndRdAmount) {
                    this.finalTransactionAmount = this.topUpAmount;
                    this.usedLenderBalance = this.loanAndRdAmount;
                } else {
                    this.finalTransactionAmount = this.loanAndRdAmount - this.lenderBalanceAmount + this.topUpAmount;
                    this.usedLenderBalance = this.lenderBalanceAmount;
                }
            } else {
                if (this.lenderBalanceAmount > this.loanAndRdAmount) {
                    this.finalTransactionAmount = 0;
                    this.usedLenderBalance = this.loanAndRdAmount;
                } else {
                    this.finalTransactionAmount = this.loanAndRdAmount - this.lenderBalanceAmount;
                    this.usedLenderBalance = this.lenderBalanceAmount;
                }
            }
        }
        if(this.showCoverTransactionCost){
            this.finalTransactionAmount += this.coverTransactionCost;
        }
        console.log('finalTransactionAmount 1360 : ',this.finalTransactionAmount);
    }

    gotoThankYouPayNow() {
        this.paymentError = '';
        this.isLoading = true;
        this.payButtonDisabled = true;
        this.canDeleteLoanFromCart =false;
        this.transactionIdsCommon();
        this.payableFinalTransactionAmount();
        let vdAmount = Number(localStorage.getItem('vdAmount'));
        (!this.showCoverTransactionCost && vdAmount == 0 ) ? localStorage.setItem('zeroTransFlag',1) : localStorage.setItem('zeroTransFlag',0);
        if(this.transactionIds.length > 0 || this.rdAmount > 0){
            this.isLoading = true;
                if(this.finalTransactionAmount === 0 && this.lenderBalanceSelected) {
                    this.payByMethod = 'lender balance';
                }
                let conId = this.contactid ? this.contactid : this.constantContactId;
                let request = {
                    contactId: conId,
                    amount: this.finalTransactionAmount,
                    transactionsIds: this.transactionIds,
                    usedLenderBalance: this.usedLenderBalance,
                    email: this.lenderEmail ? this.lenderEmail : this.guestEmail,
                    fullLenderName: this.lenderName ? this.lenderName : this.guestFName + ' ' + this.guestLName
                };
                /* request = {
                    ...request,
                    amount: this.amount,
                    usedLenderBalance: this.usedLenderBalance
                };*/
                if (this.paymentToken && this.paymentToken.object === 'token' && this.finalTransactionAmount > 0) {
                    request = {
                        ...request,
                        tokenId: this.paymentToken.id,
                        paymentTypeId: this.paymentToken.card.id
                    };
                    processPaymentByCard(request)
                        .then((data) => {
                            if (this.rdAmount && this.rdAmount > 0) {
                                this.processRDFromCart();
                            } else {
                                this.setThankYouPayNow(data);
                            }
                        }).catch((error) => {
                            this.paymentError = this.reduceErrors(error);
                            console.log('error -> ', error);
                            this.isLoading = false;
                            this.payButtonDisabled = false;
                        }).finally(() => {
                            if (!(this.rdAmount && this.rdAmount > 0)) {
                                this.isLoading = false;
                            }
                        });
                } else if (this.paymentToken && this.paymentToken.object === 'payment_method' && this.finalTransactionAmount > 0) {
                    request = {
                        ...request,
                        tokenId: this.paymentToken.id
                    };
                    processPaymentByWallet(request)
                        .then((data) => {
                            this.setThankYouPayNow(data);
                        }).catch((error) => {
                            this.paymentError = this.reduceErrors(error);
                            console.log('error -> ', error);
                            this.isLoading = false;
                            this.payButtonDisabled = false;
                        }).finally(() => {
                            this.isLoading = false;
                        });
                } else if (this.payByMethod === 'lender balance' && this.finalTransactionAmount === 0) {
                    request = {
                        ...request,
                        tokenId: '',
                        paymentTypeId: ''
                    };
                    console.log('request -> ', request);
                    processPaymentByCard(request)
                        .then((data) => {
                            if (this.rdAmount && this.rdAmount > 0) {
                                this.processRDFromCart();
                            } else {
                                this.setThankYouPayNow(data);
                            }
                        }).catch((error) => {
                            this.paymentError = this.reduceErrors(error);
                            console.log('error -> ', error);
                            this.isLoading = false;
                            this.payButtonDisabled = false;
                        }).finally(() => {
                            if (!(this.rdAmount && this.rdAmount > 0)) {
                                this.isLoading = false;
                            }
                        });
                } else if (this.rdAmount && this.rdAmount > 0) {
                    this.processRDFromCart();
                }
                this.noItemsInCart = false;
                this.isLoading = true;
        }
        else{
            this.noItemsInCart = true;
            this.isLoading = false;
        }
        //this.isLoading = false;
    }
    processRDFromCart() {
        let request = {
            contactId: this.contactid,
            tokenId: this.rdToken.id,
            paymentTypeId: this.rdToken.card.id,
            amount: this.rdAmount,
            cardResponse: JSON.stringify(this.rdToken)
        };

        this.isLoading = true;
        processRD(request)
            .then((data) => {
                this.setThankYouPayNow(data);
            }).catch((error) => {
                this.paymentError = this.reduceErrors(error);
                console.log('error -> ', error);
                this.isLoading = false;
                this.payButtonDisabled = false;
            }).finally(() => {
                this.isLoading = false;
            });
    }

    reduceErrors(error) {
        let errorMessage;
        if (error.body.message) {
            errorMessage = error.body.message;
        } else if (error.body.pageErrors) {
            errorMessage = error.body.pageErrors[0].message;
        }

        return errorMessage;
    }
    noItemsInCart = false;
    setThankYouPayNow(data) {
        this.isLoading = true;
        if (data.isError) {
            this.paymentError = data.message;
            this.isLoading = false;
        } else {
            this.OpenThankyouPageWithNavBar = true;
            this.fifthPage = false;
            this.CartModules = false;
            this.loanidfromparent = [];
            localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
            const clearloans = true;
            const deleteAllLoans = new CustomEvent('clearloans', {
                detail: clearloans
            });
            this.dispatchEvent(deleteAllLoans);
            localStorage.setItem('isVoluntary', false);
            localStorage.setItem('vdId', null);
            localStorage.setItem('isCC', null);
            this.rdData['Id'] = '';
            this.rdData['npe03__Amount__c'] = 0;
            localStorage.setItem('isTopup', false);
            localStorage.setItem('TopupTransactionId', '');
            localStorage.setItem('topupAmountfromStorage', '');
            localStorage.setItem('vdAmount', 0);
            localStorage.setItem('rdAmt',0);
            this.canMoveFromSixthPage= false;
            this.isLoading = false;
            this.isTopupOnly = false;
            if (Number(localStorage.getItem('zeroTransFlag')) == 1) {
                this.removeEmptyTransaction();
            }
        }
    }

    CloseThankYouAfterPayNow() {
        this.OpenThankyouPageWithNavBar = true;
        this.ThankYouAfterPayNow = false;
        this.CartModules = false;
        console.log('from close cart modules CloseThankYouAfterPayNow')
    }
    openMoreVouchers() {
        this.ThankYouAfterPayNow = true;
    }
    closeMoreVouchers() {
        this.ThankYouAfterPayNow = false;
    }

    get comboboxOptions() {
        return [
            { label: '$25', value: '$25' },

        ];
    }
    get combobox2Options() {
        return [
            { label: '0%', value: '0' },
            { label: '5%', value: '5' },
            { label: '10%', value: '10' },
            { label: '15%', value: '15' },
            { label: '25%', value: '25' },
            { label: 'Other', value: 'Other' },

        ];
    }

    cartItems = [
        { Id: 1, Name: 'Parichat Contribution', Amount: '$25.00' },
        { Id: 2, Name: 'Voluntary donation', Amount: '$2.50' },
    ];
    gotoCartChangeChampion() {
        this.firstPage = false;
        this.secondPage = true;
        this.createAccount = false;
        this.currentStep = "1";
        this.CartLendChangeChampion = false;
        this.CartChangeChampion = true;
    }

    setPaymentMethods() {
        this.haveLenderBalance = false;
        this.LenderbalanceChecked = false;
        //this.lenderBalanceSelected = false; //to retain checkboxes value
        if (this.testTotal > 0) {
            this.amountZero = false;
        }
        if (this.loanidfromparent.length > 0) {
            this.haveLoaninCart = true;
        }
        if (this.loanidfromparent.length < 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;
        }
        else if (this.loanidfromparent.length < 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        else if (this.loanidfromparent.length < 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
            }
            //this.haveLenderBalance = true;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
            }
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == false
            && this.changeChampionTemplate == false) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
            }
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
            }
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;

        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        if (this.isGuest == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;
        }


    }
    
    //It will take us to 3rd page
    processingAmount = 0;
    errorOnRDAmountNull=false;
    gotoSecondPage() {
        this.noItemsInCart = false; 
        this.setPaymentMethods();
        if(this.showCoverTransactionCost || this.lenderBalanceSelected){
            updateTransactionCost(this); // updating coverTransactionCost according to new Voluntary Donation
            if(this.lenderBalanceSelected){
                this.setRemainingBalance();
                this.processingAmount = parseFloat((Number(this.remainingBalanceAmount) + Number(this.coverTransactionCost)).toFixed(2));
                this.onUseLenderbalance({'target' : { checked : true},'detail' : { checked : true}});
            }
            else{
                this.processingAmount = parseFloat((Number(this.testTotal) + Number(this.coverTransactionCost)).toFixed(2));
            }
        }
        else{
            this.processingAmount = this.testTotal;
        }
        let lvdamt = this.loanAndRdAmount;
        let vdAmount = localStorage.getItem('vdAmount');
        if (Number(vdAmount) >= 0) {
            this.vdAmount = vdAmount;
        }
        if (this.LenderTopup == true && this.topUpAmount < 2) {
            this.errorMessageTopup = true;
        }
        else if(this.LenderTopup && !this.voluntaryDonation){
            this.createTopupDonationRecord();
        } 
        else{
            this.errorMessageTopup = false;
        }
        console.log('error messages--> '+this.errorMessageTopup + ' '+ this.errorMessage+' '+this.errorOnRDAmountNull)
        if (this.loanidfromparent != undefined && this.testTotal >= 100 && this.defaultDonationPercentage >= 15 &&
            this.loanidfromparent.length >= 2 && this.voluntaryDonationClosed == false
            && this.changeChampionTemplate == false && this.errorMessageTopup == false
            && this.errorMessageTopupkKYCPending == false && this.errorMessageTopupNull == false
            && this.errorOnRDAmount == false && this.errorMessage == false
            && this.isGuest == false && this.isChampion ==false
        ) {
            //this.firstPage=false;
            this.OpenCCRedirectMessage = true;
            //this.secondPage=true;
            //this.createAccount=true;
            //this.currentStep = "2";
            this.CartLendChangeChampion = false;
            this.CartChangeChampion = false;
            this.amountZero = false;
        }
        else if (this.testTotal == 0) {
            this.amountZero = true;
        }
        
        else if (this.errorMessageTopup == false && this.errorMessage == false 
        && ((this.changeChampionTemplate == false && this.errorOnRDAmountNull==false) 
        || (this.changeChampionTemplate == true && this.errorOnRDAmountNull==false))) {
            this.showGuestError = false;
            this.secondPage = false;
            this.checkOutasGuest = false;
            this.createAccount = false;
            this.signIn = false;

            this.rdToken = {};
            this.paymentToken = {};
            this.createTokenForRd = false;
            this.cardPayment = false;
            this.paypalPayment = false;
            this.googlePayment = false;

            if(this.showGooglePay) {
                this.isLoading = true;
                this.payableFinalTransactionAmount();
            }

            this.thirdPage = false;

            this.thirdPage = true;
            this.currentStep = "3";
            setTimeout(() => {
                this.isLoading = false;
            }, 5000);
        }
        console.log('this.coverTransactionCost 1784 ',this.coverTransactionCost);
    }
    createTopupDonationRecord(){
        localStorage.setItem('vdAmount', 0);
        if (this.contactid != null || this.contactid != undefined) {
            this.pageData['Lender__c'] = this.contactid;
        }
        if (this.pageData['Id'] != '' && this.pageData['Id'] != null && this.pageData['Id'] != undefined && this.pageData['Id'] != 'null') {
            this.pageData['Id'] = this.pageData['Id'];
        }
        let topupTransCost = ((this.LenderTopup && this.showCoverTransactionCost) ? parseFloat((Number(this.tAmt * 0.03)).toFixed(2)) : 0);
        this.pageData['Amount__c'] = topupTransCost;
        //this.pageData['Amount__c'] = this.showCoverTransactionCost ? parseFloat((((voluntaryDonationAmt+(currentCartItemsTotalAmount))*0.03) + voluntaryDonationAmt).toFixed(2)):  voluntaryDonationAmt;
        this.pageData['Type__c'] = 'Donation';
        this.pageData['isTopupOnly__c'] = true;
        this.isTopupOnly = true;
        this.pageData['Transaction_Fee__c'] = ( this.showCoverTransactionCost ) ? this.coverTransactionCost : 0;
        console.log('this.pageData 1795 : ',JSON.stringify(this.pageData));
        if (this.pageData['Amount__c'] >= 0 && this.LenderTopup == true) {
            createVDTransaction({ rec: this.pageData })
                .then(result => {
                    console.log('createVDTransaction : ',JSON.stringify(result));
                    if (result.Id.length >= 15 || result.Id.length >= 18) {
                        localStorage.setItem('vdId', result.Id);
                        this.pageData['Id'] = result.Id;
                        this.vdAmount = result.Amount__c;      
                        this.coverTransactionCost = parseFloat((Number(this.tAmt * 0.03)).toFixed(2));
                        if(this.showCoverTransactionCost){
                            this.testTotal = parseFloat((this.tAmt).toFixed(2));
                            this.totalVDAmount = this.coverTransactionCost;
                        }
                        else{
                            this.testTotal = parseFloat(this.tAmt.toFixed(2));
                            this.totalVDAmount = 0;
                        }
                        this.callUpdateDonationRecord(); // update record
                    }
                })
                .catch(error => {
                    console.log('error 1818 ', JSON.stringify(error));
                    localStorage.setItem('vdId', null);
                    this.pageData['Id'] = null;
                })
        }
    }
    
    signInAccount() {
        this.secondPage = true;
        this.createAccount = false;
        this.signIn = true;
        this.checkOutasGuest = false;
    }
    createAccountPage() {
        this.secondPage = true;
        this.createAccount = true;
        this.signIn = false;
        this.checkOutasGuest = false;

    }
    gotoCheckOut() {
        this.secondPage = true;
        this.checkOutasGuest = true;
        this.createAccount = false;
        this.signIn = false;
    }
    gotoThirdPage() {
        if (this.termCheck == false || this.guestEmail == undefined || this.guestEmail == '' || this.guestFName == '' || this.guestLName == '' || this.guestFName == undefined || this.guestLName == undefined) {
            this.showGuestError = true;
        } else {
            this.showGuestError = false;
            this.secondPage = false;
            this.checkOutasGuest = false;
            this.createAccount = false;
            this.signIn = false;

            this.rdToken = {};
            this.paymentToken = {};
            this.createTokenForRd = false;
            this.cardPayment = false;
            this.paypalPayment = false;
            this.googlePayment = false;

            this.thirdPage = true;
            this.currentStep = "3";
        }
    }
    gotoCartSecondPage() {
        if (this.termCheck == false || this.guestEmail == undefined || this.guestEmail == '' || this.guestFName == '' || this.guestLName == '' || this.guestFName == undefined || this.guestLName == undefined) {
            this.showGuestError = true;
        } else {
            var isCC = localStorage.getItem('isCC')
            if (isCC != undefined && isCC != 'undefined') {
                this.checkPreviousChangeChampion();
            }
            if (this.changeChampionTemplate == undefined || this.changeChampionTemplate == 'undefined') {
                this.changeChampionTemplate = false;
            }
            this.showGuestError = false;
            this.secondPage = true;
            this.checkOutasGuest = false;
            this.createAccount = false;
            this.signIn = false;

            this.createTokenForRd = false;
            this.cardPayment = false;
            this.paypalPayment = false;
            this.thirdPage = false;

            this.thirdPage = false;
            this.currentStep = "2";
            this.firstPage = false;
        }
    }

    createTokenForRd = false;

    ifCardPayment() {
        this.transactionIdsCommon();
        if (!this.cardPayment) {

            if (this.rdAmount && this.rdAmount > 0) {
                this.createTokenForRd = true;
            }

            this.isLoading = true;

            this.rdToken = {};
            this.paymentToken = {};
            this.cardPayment = true;
            this.paypalPayment = false;
            this.paypalPButton = false;

            this.googlePayment = false;

            this.payByMethod = 'Card';
        }
        console.log('coverTransactionCost 1918 : ',this.coverTransactionCost);
    }



    handleStripePaymentComponentLoading(event) {
        this.isLoading = event.detail;
    }

    handleGooglePayClick() {
        this.isLoading = true;

        this.payableFinalTransactionAmount();

        this.rdToken = {};
        this.paymentToken = {};
        this.createTokenForRd = false;
        this.cardPayment = false;
        this.paypalPayment = false;
        this.googlePayment = true;

        this.payByMethod = 'GooglePay';
        this.setFourthPage();
    }

    paymentDetails = '';
    paymentToken = {};
    rdToken = {};

    payButtonDisabled = false;

    gotoFourthPage(event) {

        this.paymentToken = event.detail.token;
        this.rdToken = event.detail.rdToken;
        this.setFourthPage();
    }

    setFourthPage() {
        this.payButtonDisabled = false;
        this.paymentError = '';
        this.thirdPage = false;
        if (this.LenderbalanceChecked == true) {
            this.payByMethod = 'lender balance';
        }
        if (this.noPostcode && this.noMobilePhone) {
            this.fifthPage = true;
            this.currentStep = "5";
            //this.totalLoansAndDonation();
            if (this.paymentToken && this.paymentToken.type === 'card' && this.payByMethod === 'Card') {
                this.paymentDetails = 'Card ending ' + this.paymentToken.card.last4;
            } else {
                this.paymentDetails = '';
            }
        }
        else {
            this.fourthPage = true;
            this.currentStep = "4";
        }
        console.log('coverTransactionCost 1977 : ',this.coverTransactionCost);
    }

    gotoFifthPage() {
        this.fourthPage = false;
        this.fifthPage = true;
        this.currentStep = "5";
    }

    gotoFirstPage() {
        this.fifthPage = false;
        this.firstPage = true;
    }


    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.context, CARTMC, (message) => {
            this.displayMessage(message);
        });
    }
    displayMessage(message) {
        var eventValues = message ? JSON.stringify(message, null, '\t') : undefined;
        if (eventValues != undefined) {
            eventValues = JSON.parse(eventValues);
            if (eventValues.messageToSend != 'NavBar' && eventValues.messageToSend != 'Checkout' &&
                eventValues.messageToSend != 'ChangeChampion' && eventValues.messageToSend != 'BecomeChampionAddToCart' &&
                eventValues.messageToSend != 'BecomeChampionCurrChange' && eventValues.messageToSend != 'BecomeChampionOtherCurrChange'
                // && eventValues.messageToSend =='AddToCart'
            ) {
                this.loanidfromparent = eventValues.currentRecordId;
                this.amounttocart = eventValues.amountAddedToCart;
                this.startTimer1();
                this.calculateTotalAmount();
                this.voluntaryDonation = true;
                this.createDonationTransRecord();
                localStorage.setItem('isVoluntary', true);
            } else if (eventValues.messageToSend == 'Checkout') {
                this.carecart = true;
                var isCC = localStorage.getItem('isCC')
                if (isCC != undefined && isCC != 'undefined') {
                    this.checkPreviousChangeChampion();
                }
                this.checkGuestUser();
            } else if (eventValues.messageToSend == 'ChangeChampion') {
                this.changeChampionTemplate = true;
                this.becomeChangeChampionActivate(eventValues.currentRecordId);
            } /* else{
                this.changeChampionTemplate = false;
            } */
        }
        // this.handleCart();
    }
    //ends care cart
    becomeChangeChampionActivate(amount) {

        this.errorOnRDAmount = false;
        this.rdData['npe03__Amount__c'] = amount;
        this.rdData['npe03__Contact__c'] = this.contactid;
        this.rdData['npsp__RecurringType__c'] = 'Fixed';
        this.rdData['PaymentMethod'] = 'Credit Card';
        this.rdData['CurrencyIsoCode'] = 'AUD';
        this.rdData['Payment_Gateway__c'] = 'Stripe';

        let currentCartItemsTotalAmount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            currentCartItemsTotalAmount = this.loanidfromparent
                .filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, item) => total + item.selectedAmount, 0);

        }

        this.testTotal = (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0) +
            currentCartItemsTotalAmount + this.topUpAmount +
            (currentCartItemsTotalAmount * this.donationAmount) / 100; /* + (this.isAdded ? this.amountLeftToFullyFunded : 0);*/

        //this.testTotal = parseFloat(this.testTotal.toFixed(2));

        var amt = this.rdData['npe03__Amount__c'] != undefined ? Number(this.rdData['npe03__Amount__c']) : 0;
        localStorage.setItem('rdAmt', amt);
        this.rdAmount = amt;
    }
    signInCC = false;
    showCreditCard = false;
    showPaypal = false;
    showApplePay = false;
    showGooglePay = false;
    vfPageDomain = '';
    isshowCreditCard = false;
    isshowPaypal = false;
    isshowApplePay = false;
    isshowGooglePay = false;
    usedLenderBalanceToSend;
    canMoveFromSixthPage = true;
    constantContactId = '';
    paymentDetailPaypal = {};
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }
    connectedCallback() {

        getAlert().then(res => {
            if (res != undefined) {
                res = this.htmlDecode(res);
                const evt = new ShowToastEvent({
                    message: res,
                    variant: 'info',
                    mode: 'sticky'
                });
                this.dispatchEvent(evt);
            }
        }).catch(err => {
            console.log(err);
        });

        this.isLoading = true;

        getStripePaymentConfigs().then((data) => {
            this.showCreditCard = data['Allow_Credit_Card__c'];
            this.showPaypal = data['Allow_Paypal__c'];
            this.showApplePay = data['Allow_Apple_Pay__c'];
            this.showGooglePay = data['Allow_Google_Pay__c'];
            this.isshowCreditCard = data['Allow_Credit_Card__c'];
            this.isshowPaypal = data['Allow_Paypal__c'];
            this.isshowApplePay = data['Allow_Apple_Pay__c'];
            this.isshowGooglePay = data['Allow_Google_Pay__c'];
            this.vfPageDomain = data['VF_page_domain__c'];
            this.constantContactId = data['Constant_Contact_Id__c'];

        }).finally(() => {
            this.isLoading = false;
        });

        this.subscribeMC();
        this.checkGuestUser();
        this.supportOneMoreProject = localStorage.getItem('isAdded');
        this.currentUser();
        this.handleTopup();
        this.handleCart();
        this.handleCC();
        //this.testTimer();
        this.handleVD();
        this.startTimerIfStored();
        this.getCMSContent();
        const tempId1 = 'token';
        const encodedValue1 = this.getUrlParamValue(window.location.href, tempId1);
        if (encodedValue1) {
            this.token = decodeURIComponent(encodedValue1);
        }
        const tempId2 = 'CartModules';
        const encodedValue2 = this.getUrlParamValue(window.location.href, tempId2);
        if (encodedValue2) {
            this.CartModules = decodeURIComponent(encodedValue2);
        }
        const tempIdcart = 'carecart';
        const encodedValueCart = this.getUrlParamValue(window.location.href, tempIdcart);
        if (encodedValueCart) {
            this.carecart = decodeURIComponent(encodedValueCart);
        }
        
        const tempId4 = 'OpenThankyouPageWithNavBar';
        const encodedValue4 = this.getUrlParamValue(window.location.href, tempId4);
        if (encodedValue4) {
            this.OpenThankyouPageWithNavBar = decodeURIComponent(encodedValue4);
            this.isLoading = this.OpenThankyouPageWithNavBar;
        }
        const tempId5 = 'usedLenderBalance';
        const encodedValue5 = this.getUrlParamValue(window.location.href, tempId5);
        if (encodedValue5) {
            this.usedLenderBalanceToSend = decodeURIComponent(encodedValue5);
        }
        const tempId3 = 'accesstoken';
        const encodedValue3 = this.getUrlParamValue(window.location.href, tempId3);
        if (encodedValue3) {
            this.accesstoken = decodeURIComponent(encodedValue3);

        }
        let lenderEmail = '';
        const encodedEmail = this.getUrlParamValue(window.location.href, 'email');
        if(encodedEmail) {
            lenderEmail = decodeURIComponent(encodedEmail);
        }
        let lname = '';
        const encodedName = this.getUrlParamValue(window.location.href, 'name');
        if(encodedName) {
            lname = decodeURIComponent(encodedName.replace(/_/g,' '));
        }

        let transactionIds = [];
        var paymentArrays = localStorage.getItem('myArray');
        if (paymentArrays != undefined && paymentArrays != '' && paymentArrays != 'undefined') {
            paymentArrays = JSON.parse(paymentArrays);
            transactionIds = paymentArrays.map(item => item.TransactionId).filter(Boolean);
        }
        if(!transactionIds.includes(this.pageData['Id'])){
            this.transactionIds.push(this.pageData['Id']);
        }
        if (this.TopupTransactionId != null) {
            transactionIds.push(this.TopupTransactionId);
        }
        let vdtranId = localStorage.getItem('vdId');
        if (vdtranId != '' && vdtranId != null && vdtranId != undefined && vdtranId != 'null'
            && vdtranId.length >= 15 && vdtranId.length <= 18 && !transactionIds.includes(vdtranId)) {
            transactionIds.push(vdtranId);
        }
        if (this.accesstoken != null && this.token != null && transactionIds != null) {
            capturePayPalOrder({ accesstoken: this.accesstoken, orderId: this.token })
                .then(result => {
                    if (result != null || result.length != 0) {
                        this.paymentDetailPaypal = {
                            object: 'paypal',
                            id: result.id
                        }
                        let request = {
                            contactId: result.referenceId,
                            paymentResponse: JSON.stringify(this.paymentDetailPaypal),
                            transactionsIds: transactionIds.filter(id => id !== null && id !== undefined && id != 'null' && id !== ''),
                            usedLenderBalance: this.usedLenderBalanceToSend,
                            email: lenderEmail,
                            fullLenderName: lname //this.lenderName ? this.lenderName : this.guestFName + ' ' + this.guestLName
                        };
                        console.log('request 2199 : ',JSON.stringify(request));
                        this.isLoading = true;
                        localStorage.setItem("isGetResponseFromPaypal" , 0);
                        processPayPal(request)
                        .then(result => {
                            if(result != undefined && result != null){
                                console.log('SuccessPaypal: ', JSON.stringify(result));
                                localStorage.setItem("isGetResponseFromPaypal" , 1);
                                this.usedLenderBalanceToSend = 0;
                                this.accesstoken = '';
                                this.token = '';
                                this.loanidfromparent = [];
                                localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
                                localStorage.setItem('isVoluntary', false);
                                localStorage.setItem('vdId', null);
                                localStorage.setItem('isCC', null);
                                this.rdData['Id'] = '';
                                this.rdData['npe03__Amount__c'] = 0;
                                localStorage.setItem('isTopup', false);
                                localStorage.setItem('TopupTransactionId', null);
                                localStorage.setItem('topupAmountfromStorage', null);
                                localStorage.setItem('vdAmount', 0);
                                localStorage.setItem('rdAmt',0);
                                this.isLoading = false;
                                this.isTopupOnly = false;
                                this.LenderTopup = false;
                                this.canMoveFromSixthPage = false;

                                if (Number(localStorage.getItem('zeroTransFlag')) == 1) {
                                    this.removeEmptyTransaction();
                                }
                            }

                        })
                        .catch(error => {
                            console.log('RecordUpdattion error: ', JSON.stringify(error))
                            this.canMoveFromSixthPage = false;
                            this.isLoading = false;
                            this.toastMessage('Some unexpected error occur !!. Please try again later..', 'error');
                        })
                        this.isLoading = true;
                    }
                })
                .catch(error => {
                    this.paymentError = this.reduceErrors(error) + ' Please select the payment method again';
                    console.log('OrderStatus error: ', JSON.stringify(error))
                    this.isLoading = false;
                })
        }
    }
    toastMessage(message, variant ){
        const evt = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    sectionName = 'Why LWC';
    getCMSContent() {
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                        if (val.contentNodes.Tag.value == 'ChangeChampionWindow') {
                            var boxTitle = val.contentNodes.Title.value;
                            if (boxTitle != undefined) {
                                var nboxTitle = boxTitle.split('$');
                                var i = 0;
                                var arr2 = [];
                                for (var val2 of nboxTitle) {
                                    var obj = {};
                                    if (i != 0) {
                                        obj = { 'changeColor': true, 'body': '$' + val2.substring(0, val2.indexOf(' ')) };
                                        var obj2 = { 'changeColor': false, 'body': val2.substring(val2.indexOf(' ')) };
                                        i++;
                                        arr2.push(obj);
                                        arr2.push(obj2);
                                        continue;
                                    } else {
                                        obj = { 'changeColor': false, 'body': val2 };
                                    }
                                    i++;
                                    arr2.push(obj);
                                }
                                this.nboxTitle = arr2;
                            }
                            var body = this.htmlDecode(this.htmlDecode(val.contentNodes.Body.value));
                            if (body != undefined) {
                                var changeChampionWindowBody = body.split('$');
                                var i = 0;
                                var arr3 = [];
                                for (var val3 of changeChampionWindowBody) {
                                    var obj = {};
                                    if (i != 0) {
                                        obj = { 'changeColor': true, 'body': '$' + val3.substring(0, val3.indexOf(' ')) };
                                        var obj3 = { 'changeColor': false, 'body': val3.substring(val3.indexOf(' ')) };
                                        i++;
                                        arr3.push(obj);
                                        arr3.push(obj3);
                                        continue;
                                    } else {
                                        obj = { 'changeColor': false, 'body': val3 };
                                    }
                                    i++;
                                    arr3.push(obj);
                                }
                                this.changeChampionWindowBody = arr3;
                            }
                            //this.boxButton = val.contentNodes.ButtonName.value;
                        }
                    }
                }
            }
        }).catch(e => {
            console.log('OUTPUT : error ', e.toString());
            console.log('OUTPUT : error ', e);
        })
    }

    handleVD() {
        let isVD = localStorage.getItem('isVoluntary');
        let isVDid = localStorage.getItem('vdId');
        let defaultValue = localStorage.getItem('defaultDonationPercentage');
        if (defaultValue != null && defaultValue != 'null'
            && defaultValue != undefined && defaultValue != 'undefined') {
            this.defaultDonationPercentage = Number(defaultValue);
            this.defaultDonationPercentageValue = defaultValue;
            this.createDonationTransRecord();
        }
        if (this.defaultDonationPercentage != '0' && this.defaultDonationPercentage != '10' 
        && this.defaultDonationPercentage != '15' && this.defaultDonationPercentage != '25') {
            this.otherPercentage = true;
            this.otherPercentageValue = Number(this.defaultDonationPercentage);
            this.defaultDonationPercentageValue = 'Other';
        }
        if (isVD == 'true') {
            this.voluntaryDonation = true;

        }
        if (isVDid != '' && isVDid != null && isVDid != undefined && isVDid != 'null'
            && isVDid.length >= 15 && isVDid.length <= 18) {
            this.pageData['Id'] = isVDid;
        }
        this.calculateTotalSelectedAmount();
    }
    handleCC() {

        this.changeChampionTemplate = localStorage.getItem('isCC');
        if (this.changeChampionTemplate != 'true') {
            this.changeChampionTemplate = false;
        }
        else if (this.changeChampionTemplate == 'true') {
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        let rd = localStorage.getItem('RDid');
        let rdAmt = localStorage.getItem('rdAmt');
        if (rd != null || rd != undefined) {
            this.rdData['Id'] = rd;
            this.rdData['npe03__Amount__c'] = rdAmt;
            this.errorOnRDAmountNull = false;
            this.rdAmount = this.rdData['npe03__Amount__c'];
            this.calculateTotalSelectedAmount();
        }
    }
    handleTopup() {
        let isTopup = localStorage.getItem('isTopup');
        this.TopupTransactionId = localStorage.getItem('TopupTransactionId');
        const topupAmountfromStorage = localStorage.getItem('topupAmountfromStorage');
        if (isTopup == 'true') {
            if (this.TopupTransactionId != null && this.TopupTransactionId != 'null') {
                this.topupData['Id'] = this.TopupTransactionId;
            }
            else {
                this.topupData['Id'] = null;
            }

            this.LenderTopup = true;
            this.topUpAmount = Number(topupAmountfromStorage);
            this.topUpAmount1 = '$'+this.topUpAmount;
            this.calculateTotalSelectedAmount();
        }
        this.calculateTotalSelectedAmount();

    }
    contactChampion = false;
    currentUser() {
        getCurrentUser()
            .then(result => {
                this.contactid = result.ContactId;
                this.contactChampion = result.Contact!= undefined ? result.Contact.Champion__c : '';
            })
            .catch(error => {
                console.log('error currentUser ', JSON.stringify(error))
            })
    }
    checkGuestUser() {
        isGuestUser().then(isGuestUser => {
            this.OpenCCRedirectMessage = false;
            this.checkOutasGuest = false;
            this.createAccount = false;
            this.signIn = false;
            this.firstPage = false;
            this.amountZero = false;
            this.isGuest = isGuestUser;
            if (isGuestUser == true || isGuestUser == undefined || isGuestUser == null) {
                this.thirdPage = false;
                this.currentStep = "1";
                this.secondPage = false;
                this.firstPage = true;
                this.checkOutasGuest = true;
                this.guestCheckout = false;
                this.haveLenderBalance = false;
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
            } else {
                this.currentStep = "2";
                this.secondPage = true;
                this.thirdPage = false;
                this.firstPage = false;
                this.checkOutasGuest = false;
                this.guestCheckout = false;
                setTimeout(() => {
                    var isCC = localStorage.getItem('isCC')
                    if (isCC != undefined && isCC != 'undefined') {
                        this.checkPreviousChangeChampion();
                    }
                }, 0);
            }
        }).catch(err => {
            console.log('Error:', err);
        })
    }
    idsToUpdate = [];
    updateTransactions() {
        for (const item of this.loanidfromparent) {
            if (item.TransactionId != undefined) {
                this.idsToUpdate.push(item.TransactionId);
            }

        }
        if (this.pageData['Id'] != null &&
            this.pageData['Id'] != 'null' &&
            this.pageData['Id'] != '' &&
            this.pageData['Id'] != undefined &&
            this.pageData['Id'] != 'undefined') {
            this.idsToUpdate.push(this.pageData['Id']);
        }
        if (this.TopupTransactionId != null &&
            this.TopupTransactionId != 'null' &&
            this.TopupTransactionId != '' &&
            this.TopupTransactionId != undefined &&
            this.TopupTransactionId != 'undefined') {
            this.idsToUpdate.push(this.TopupTransactionId);
        }
        if (this.contactid != undefined || this.contactid != 'undefined' || this.contactid != null) {
            updateTransactionRecords({ rec: this.idsToUpdate, conId: this.contactid })
                .then(result => {
                    console.log('updated successfully with current lenders ', result);
                })
                .catch(error => {
                    console.log('error updating current user ', JSON.stringify(error))
                })
        }
    }
    handleCart() {
        var fromCart = localStorage.getItem('fromCart');
        if(fromCart =='true' || fromCart == true){
            this.CartModules = true;
            this.carecart = true;
            localStorage.setItem('fromCart', false);
        }
        var myA = localStorage.getItem('myArray');
        if (myA != undefined && myA != '' && myA != 'undefined') {
            this.storedArray = JSON.parse(localStorage.getItem('myArray'));
        }

        if (this.storedArray) {
            // Use the stored array on your page
            this.loanidfromparent = this.storedArray;
            let istimerLoading = localStorage.getItem('timerLoading');
            if (istimerLoading == 'true') {
                if (this.loanidfromparent.length > 0) {
                    this.timerLoading = true;
                }
            }
        } else {
            // Handle the case where the array hasn't been stored yet
            console.log('Array not found in local storage');
        }
        var isCC = localStorage.getItem('isCC')
        if (isCC != undefined && isCC != 'undefined' && isCC == 'true' ) {
            this.changeChampionTemplate = true;;
        } else {
            this.changeChampionTemplate = false;
        }
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0 || this.changeChampionTemplate == true) {
            this.calculateTotalSelectedAmount();
            setTimeout(() => {
                this.updateTransactions();
            }, 5000)

        }
        this.debounceTimeout = null;
        const currentPageUrl = window.location.href;
        var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s') + 3);
        var createAcc = currentPageUrl2.substring(0, currentPageUrl2.length - 2) + 'secur/CommunitiesSelfRegUi';
        this.navComponentLinks = {
            'HomePage': currentPageUrl2 + 'homepage',
            'AboutUs': currentPageUrl2 + 'aboutus',
            'login': currentPageUrl2 + 'login',
            'ContactUs': currentPageUrl2 + 'carecontactus',
            'ViewAllLoans': currentPageUrl2 + 'careviewallloans',
            'BecomeChangeChampion': currentPageUrl2 + 'carebecomechangechampion',
            'OurImpact': currentPageUrl2 + 'ourimpact',
            'CareHelpcentre': currentPageUrl2 + 'carehelpcentre',
            'CareDashboard': currentPageUrl2 + 'login',
            'login': currentPageUrl2 + 'login',
            'createAccount': createAcc,
            'cd':currentPageUrl2 + 'caredashboard'
        };
        if (window.location.href == this.navComponentLinks['cd']) {
            var sessionVal = sessionStorage.getItem('UniqueValue');
            if (sessionVal != '' && sessionVal != ' ' && sessionVal != undefined && sessionVal == '1234') {
                this.carecart = true;
                this.CartModules = true;
                this.firstPage = true;
                this.signInCC = true;
                sessionStorage.setItem('UniqueValue', undefined);
                var isCC = localStorage.getItem('isCC')
                if (isCC != undefined && isCC != 'undefined') {
                    this.checkPreviousChangeChampion();
                }
            }
        }
        if (currentPageUrl.includes('careviewallloans')) {
            this.isVisible = false;
        }
        else if (currentPageUrl.includes('homepage')) {
            this.violet = false;
        }
        else if (currentPageUrl.includes('careborrowerspage')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('aboutmicrofinancing')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('aboutus')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('ourimpact')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('carecontactus')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('carenewsandupdates')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('careblogpost')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('carehelpcentre')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('carebecomechangechampion')) {
            this.yellow = false;
        }
        else if (currentPageUrl.includes('caresearchresults')) {
            this.yellow = false;
        }
    }
    get timeDisplayFormat() {
        const minutes = Math.floor(this.setTime / 60);
        const seconds = this.setTime % 60;
        if(this.loanidfromparent.length > 0){
            this.timerLoading = true;
            return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        }
        else{
            this.timerLoading = false;
            return 0;
        }
        
    }
    @api startTimer1(){
    this.isTimerStarts = false;
    this.setTime = 0;
    this.startTimer(2700);
    }
    @api isTimerStarts = false;
    @api
startTimer(duration) {
    // Calculate the timer's end time
    const endTime = new Date().getTime() + duration * 1000; // Convert seconds to milliseconds
    this.timerstopped = false;
    // Store the end time in local storage
    localStorage.setItem('timerEndTime', endTime);

    // Initialize the timerInterval
    if (this.timerInterval) {
        clearInterval(this.timerInterval);
    }

    // Start the timer
    this.timerInterval = setInterval(() => {
        const currentTime = new Date().getTime();
        const timeRemaining = Math.max(0, endTime - currentTime) / 1000; // Convert back to seconds

        this.setTime = Math.ceil(timeRemaining);
        localStorage.setItem('setTime', this.setTime);

        if (this.setTime == 0 && this.timerstopped == false) {
            this.stopTimer();
            this.timerstopped = true;
        }
    }, 1000);
}

// Start the timer if a timer is already in progress
startTimerIfStored() {
    const storedEndTime = parseInt(localStorage.getItem('timerEndTime'));
    if (!isNaN(storedEndTime)) {
        const currentTime = new Date().getTime();
        const timeRemaining = Math.max(0, storedEndTime - currentTime) / 1000;

        this.setTime = Math.ceil(timeRemaining);

        if (this.setTime > 0) {
            this.startTimer(this.setTime);
        }
    }
}

    stopTimer() {
        clearInterval(this.timerInterval);
        this.setTime =0
        localStorage.setItem('setTime', 0);
        this.timerInterval = null;
        this.totalCartAmount = 0;
        this.clearArray();
        const deleteAllFromParentComponent = new CustomEvent('deleteallloans', {
            detail: this.loanidfromparent
            
        });
        if(this.loanidfromparent.length >0){
            this.dispatchEvent(deleteAllFromParentComponent);
        }
        for (const item of this.loanidfromparent) {
            if (item.TransactionId != undefined) {
                this.idsToDelete.push(item.TransactionId);
            }
        }
        if (this.pageData['Id'] != null &&
            this.pageData['Id'] != 'null' &&
            this.pageData['Id'] != '' &&
            this.pageData['Id'] != undefined &&
            this.pageData['Id'] != 'undefined') {
            this.idsToDelete.push(this.pageData['Id']);
        }
        if (this.idsToDelete.length != 0 && this.canDeleteLoanFromCart ==true) {
            removeTransactionRecords({ recordsToDelete: this.idsToDelete })
                .then(result => {
                    this.loanidfromparent = [];
                    localStorage.setItem('myArray',JSON.stringify(this.loanidfromparent));
                    this.idsToDelete = [];
                    this.totalCartAmount = 0;
                    this.pageData['Id'] = null;
                    localStorage.setItem('timerLoading', false);
                    this.timerLoading = false;
                    this.TopupTransactionId = null;
                    localStorage.setItem('vdAmount', 0);
                    localStorage.setItem('isTopup', false);
                    localStorage.setItem('TopupTransactionId', null);
                    localStorage.setItem('topupAmountfromStorage', 0);
                })
                .catch(error => {
                    console.log('error deleting bulky items ', JSON.stringify(error))
                })
        }
        this.loanidfromparent = [];
        this.calculateTotalSelectedAmount();
        this.testTotal = 0;
        this.topUpAmount = 0;
        this.topUpAmount1 = 0;
        this.rdData['npe03__Amount__c'] =0;
        this.donationAmount = '15';
        this.isAdded = false;
        localStorage.setItem('isTopup', false);
        localStorage.setItem('TopupTransactionId', null);
        localStorage.setItem('topupAmountfromStorage', 0);
        localStorage.setItem('isVoluntary', false);
        localStorage.setItem('defaultDonationPercentage', null);
        localStorage.setItem('vdId',null);
        this.voluntaryDonation = false;
        this.TopupTransactionId = null;
        this.pageData['Id'] = null;
        localStorage.setItem('myArray',JSON.stringify(this.loanidfromparent));
    }
    clearArray() {
        const overflow = true;
        const sentFromNavBar = new CustomEvent('fromnavbar', { detail: overflow });
        this.dispatchEvent(sentFromNavBar);
    }
    openMenu() {
        this.isMenuOpen = true;
        this.overflowFalse();
    }
    closeMenu() {
        this.isMenuOpen = false;
        this.overflowTrue();
    }
    SearchMenuOpen() {
        this.isSearchMenuOpen = true;
        this.overflowFalse();
    }
    closeSearchMenu() {
        this.isSearchMenuOpen = false;
        this.overflowTrue();
    }
    handleSignIn(event) {
        localStorage.setItem('fromCart',true);
        var val = event.target.dataset.value;
        sessionStorage.setItem('UniqueValue', '1234');
        this.isGuest = false;
        if (val == 'SignIn') {
            window.location.href = this.navComponentLinks.login;
        } else if (val == 'Create') {
            window.location.href = this.navComponentLinks.createAccount;
        } else if (val == 'gmail') {
            // window.location.href = 'https://accounts.google.com/o/oauth2/auth/oauthchooseaccount?response_type=code&client_id=95925662322-jroo0m34qta6c7f2tkfhadkes4l9rr79.apps.googleusercontent.com&redirect_uri=https%3A%2F%2Ftest.salesforce.com%2Fservices%2Fauthglobalcallback&scope=email%20openid%20profile&state=CAAAAYrP1B9YMDAwMDAwMDAwMDAwMDAwAAAA9uW564tEF1Wcwta7K2TM42GBb_ytLK6d9ixGtFYTD8DIvZ1RVizN3m0wZFPFB6fxR8EBRWRjO121gzFss_exP3gOf3uuZyv_se-ofWObCDD95hWpNjkE3oc_vXwiMdDgXiIYw3TacXxyovle9AhIzVIzXIyr15XeYPOtRC5htnm7zckUE4EBRyxSav9_q8UnzBxTiTWYfwbKOXhfNdN-rVYOIr6-ilJbr9gKOlkOY8WMx1HhJkO_0iPDmidJz24dXVWLqmPJ1Dd-6KnE36_V29snQpajucGB0bhphR2VDSzA9mZRVid7Zf0K8iBPrbMo6qn2un4HxflGkyma71ME27HNjElr506e-F9XGhrG7Prdyu5bWuFptFy6WNH84rVRlgsVtoGwxAp6Vtxa7Sv5-79OYEEQnmhrLlm0hbxnQzf6tQEW2mTLT83NNbZVa9QzA_2lccsXRi3EH2Jw4xkKd-6Y4Oxh-Ibt30KL9TUjDc0HWu6M67ZzZP3HaMCTQ1Xx7U_BUQ6SANMfXVHUki2d4zIukUNM8YFJVHZWuVoaud4fOxvCp25n85JlFaG8-_5gbg%3D%3D&service=lso&o2v=1&theme=glif&flowName=GeneralOAuthFlow';
        } else if (val == 'facebook') {
            window.location.href = '';
        } else if (val == 'Forgot') {
            window.location.href = this.navComponentLinks.login + '/ForgotPassword'
        }
    }
    handleContinueAsGuest() {
        this.checkOutasGuest = true;
    }
    handleInputChangeGuest(event) {
        var fieldName = event.target.dataset.value;
        var value = event.target.value;
        if (fieldName == 'FirstName') {
            this.guestFName = value;
        } else if (fieldName == 'LastName') {
            this.guestLName = value;
            this.lenderName = this.guestFName +' '+ this.guestLName;
        } else if (fieldName == 'Email') {
            this.guestEmail = value;
            this.lenderEmail = this.guestEmail;
        } else if (fieldName == 'Terms') {
            this.termCheck = event.target.checked;
        }
    }
    openLoginOrDashboard() {
        const currentUrl = window.location.href;
        if (this.contactid != null) {
            const newUrldash = currentUrl.replace(/\/s\/[^/]+/, '/s/' + 'caredashboard');
            window.location.assign(newUrldash);
        } else {
            const newUrllogin = currentUrl.replace(/\/s\/[^/]+/, '/s/' + 'login/');
            window.location.assign(newUrllogin);
        }
    }
    isRemainingBalance = false;
    LenderbalanceChecked = false;
    lenderBalanceSelected = false;
    isTopupAdded = false;
    onUseLenderbalance(event) {
        if(this.showGooglePay) {
            this.isLoading = true;
        }
        this.lenderBalanceSelected = event.target.checked;
        if (event.target.checked == true) {
            if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == false
                && this.changeChampionTemplate == false) {
                this.showCreditCard = false;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = true;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == false
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2); 
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == true
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);              
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == true
                && this.changeChampionTemplate == false) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
                this.LenderbalanceChecked = false;
                this.processingAmount =parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
            }
            else if (this.LoanAndRDAmount > this.lenderBalanceAmount && this.lenderBalanceAmount != 0 &&
                this.LenderTopup == true
                && this.changeChampionTemplate == false) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
                this.LenderbalanceChecked = false;
                this.isRemainingBalance = true;
                this.processingAmount = parseFloat((this.LoanAndRDAmount - this.lenderBalanceAmount)
                    + this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                
            }
            else if (this.LoanAndRDAmount > this.lenderBalanceAmount && this.lenderBalanceAmount != 0 &&
                this.LenderTopup == false
                && this.changeChampionTemplate == false) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
                this.LenderbalanceChecked = false;
                this.isRemainingBalance = true;
                this.processingAmount = parseFloat((this.LoanAndRDAmount - this.lenderBalanceAmount)
                    + this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                
            }
            else if (this.LoanAndRDAmount > this.lenderBalanceAmount && this.lenderBalanceAmount != 0 &&
                this.LenderTopup == true
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat((this.LoanAndRDAmount - this.lenderBalanceAmount)
                    + this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                
            }
            else if (this.LoanAndRDAmount > this.lenderBalanceAmount && this.lenderBalanceAmount != 0 &&
                this.LenderTopup == false
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat((this.LoanAndRDAmount - this.lenderBalanceAmount)
                    + this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                
            }
        }
        else if (event.target.checked == false) {
            if (this.showCoverTransactionCost) {
                const testTotalNumber = Number(this.testTotal);
                this.processingAmount = (testTotalNumber + parseFloat(Number(testTotalNumber * 0.03).toFixed(2))).toFixed(2);
            } else {
                this.processingAmount = Number(this.testTotal).toFixed(2);
            }
            this.isRemainingBalance = false;
            if (this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
            }
            else if (this.changeChampionTemplate == false) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
                this.LenderbalanceChecked = false;
            }
        }
        this.setRemainingBalance();
        this.callUpdateDonationRecord();
    }
    setRemainingBalance() {
        console.log('setRemainingBalance : ',this.LoanAndRDAmount);
        if (this.lenderBalanceSelected === true) {
            if (this.LoanAndRDAmount < this.lenderBalanceAmount) {
                this.withLenderBalanceOnlyTemplate = true;
                this.withLenderBalanceAndOthersTemplate = false;
                this.isRemainingBalance = false;
                this.remainingBalanceAmount = 0;
            }
            else if (this.LoanAndRDAmount > this.lenderBalanceAmount && this.lenderBalanceAmount != 0) {
                this.withLenderBalanceOnlyTemplate = false;
                this.withLenderBalanceAndOthersTemplate = true;
                this.remainingBalanceAmount = parseFloat(this.LoanAndRDAmount - this.lenderBalanceAmount).toFixed(2);
                /*(this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)
                - (this.LenderTopup == true? this.topUpAmount:0);*/
                this.isRemainingBalance = true;
                updateTransactionCostIfLenderBalanceEnabled(this);
            }
        }
        else if (this.lenderBalanceSelected == false) {
            this.isRemainingBalance = false;
            this.remainingBalanceAmount = 0;
        }
        this.payableFinalTransactionAmount();
        if(this.showGooglePay && this.finalTransactionAmount > 0 ) {
            this.showGooglePay = false;
            setTimeout(() => {
                this.showGooglePay = true;
            }, 100);
        } else {
            this.isLoading = false;
        }
    }
    
    haveLoaninCart = false;
    LoanAndRDAmount = 0;
    get loanAndRdAmount() {
        let currentCartItemsTotalAmount = 0;
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0) {
            currentCartItemsTotalAmount = this.loanidfromparent
                .filter(record => typeof record.selectedAmount === 'number')
                .reduce((total, item) => total + item.selectedAmount, 0);
        }
        //this.coverTransactionCost = currentCartItemsTotalAmount!=null ? parseFloat((currentCartItemsTotalAmount * 0.03).toFixed(2)) : 0; //Cover Transaction Cost
        let vdAmount = localStorage.getItem('vdAmount');
        console.log('vdAmount from 2941 ',vdAmount)
        if (Number(vdAmount) >= 0) {
            this.vdAmount = vdAmount;
        }
        let amt = currentCartItemsTotalAmount + (this.voluntaryDonation == true ? (parseFloat(currentCartItemsTotalAmount.toFixed(2)) * Number(this.defaultDonationPercentage) / 100) : 0); 
        if (amt > 0) {
            this.haveLoaninCart = true;
        }
        else if (amt <= 0) {
            this.haveLoaninCart = false;
        }
        console.log('coverTransactionCost 2947 : ',this.coverTransactionCost);
        this.LoanAndRDAmount = parseFloat(amt.toFixed(2));
        this.coverTransactionCost = (this.LoanAndRDAmount!=null && this.LoanAndRDAmount!=0)? parseFloat((parseFloat(Number(this.LoanAndRDAmount).toFixed(2)) * 0.03).toFixed(2)) : (this.processingAmount != 0 && this.processingAmount != null) ? parseFloat((parseFloat(Number(this.processingAmount).toFixed(2)) * 0.03).toFixed(2)) : 0;
        if(this.showCoverTransactionCost){
            this.coverTransactionCost = (this.LoanAndRDAmount!=null && this.LoanAndRDAmount!=0) ? parseFloat((parseFloat(Number(this.LoanAndRDAmount).toFixed(2)) * 0.03).toFixed(2)) : (this.processingAmount != 0 && this.processingAmount != null) ? parseFloat((parseFloat(Number(this.processingAmount).toFixed(2)) * 0.03).toFixed(2)) : 0;
        }
        if(this.lenderBalanceSelected){
            this.coverTransactionCost = parseFloat((parseFloat(Number(this.remainingBalanceAmount).toFixed(2)) * 0.03).toFixed(2));
        }   
        if(this.LenderTopup && !this.voluntaryDonation && this.tAmt > 1){
            this.coverTransactionCost = parseFloat((Number(this.tAmt * 0.03)).toFixed(2));
        }
        console.log('coverTransactionCost 2956 : ',this.coverTransactionCost);
        return parseFloat(amt.toFixed(2));
    }
    RDAmount = 0;
    rdAmount = 0;
    closechangeChampionTemplate() {
        this.changeChampionTemplate = false;
        localStorage.setItem('isCC', false);
        localStorage.setItem('SelectedCCIndex', false);
        localStorage.setItem('SelectedCCAmount', 0);
        localStorage.setItem('OtherChecked', false);
        localStorage.setItem('RDid', null);
        localStorage.setItem('rdAmt', 0);
        this.rdData['Id'] = null;
        this.rdData['npe03__Amount__c'] = 0;
        this.rdAmount = 0;
        this.calculateTotalSelectedAmount();
    }
    isprocessingAmount = true;
    gotoHelpCenter(){
        window.location.assign('carehelpcentre')
    }
    //Cover Transaction Cost
    onCoverTransactionCost(event){
        let isChecked = event.target.checked;
        
        if(!isChecked){
            this.processingAmount = parseFloat((Number(this.processingAmount) - Number(this.coverTransactionCost)).toFixed(2));
        }else{
            this.processingAmount = parseFloat((Number(this.processingAmount) + Number(this.coverTransactionCost)).toFixed(2));        
        }
        this.showCoverTransactionCost = isChecked;
        this.callUpdateDonationRecord();
        console.log('onCoverTransactionCost 2995: ',this.showCoverTransactionCost);
    }
    callUpdateDonationRecord(){
        console.log('coverTransactionCost 2992 : ',this.coverTransactionCost);
        console.log('vdAmount 2993 : ',localStorage.getItem('vdAmount'));
        this.isTopupOnly = (this.isTopupOnly) ? true : false;
        if(this.LenderTopup || (this.pageData['Id'] != null && this.pageData['Id'] != undefined && this.pageData['Id'] != '')){
            updateDonationRecord({ coverTransactionCost : this.coverTransactionCost, voluntaryDonation : localStorage.getItem('vdAmount'), contactId : this.contactid,  showTransactionCoverCost : this.showCoverTransactionCost, 
            transactionRec : localStorage.getItem('vdId'), isTopupOnly : this.isTopupOnly})
            .then(result => {
                if(result!=null){
                    this.pageData['Id'] = result.Id;
                    localStorage.setItem('vdId', result.Id);
                    // localStorage.getItem('vdId');
                    // if(!this.voluntaryDonation){
                    //     localStorage.setItem('vdAmount', 0);
                    // }
                }
            })
            .catch(error => {
                console.log('error 3010', JSON.stringify(error))
            })
        }
        
    }
}