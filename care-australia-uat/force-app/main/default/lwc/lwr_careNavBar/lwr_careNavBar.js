import { LightningElement, track, api, wire } from 'lwc';
import Hamburger from '@salesforce/resourceUrl/HamburgerWhite';
import MagGlass from '@salesforce/resourceUrl/MagnifyingGlass';
import UserIcons from '@salesforce/resourceUrl/NavUser';
import ShoppingCart from '@salesforce/resourceUrl/GroceryStore';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import LWCLogo from '@salesforce/resourceUrl/LWCLogoSvg';
import UserSVG from '@salesforce/resourceUrl/UserSVG';
import FbIcon from '@salesforce/resourceUrl/FacebookLogo';
import GooIcon from '@salesforce/resourceUrl/GoogleIcon';
import AppIcon from '@salesforce/resourceUrl/AppleIcon';
import AExpress from '@salesforce/resourceUrl/AmericanExpress';
import CC from '@salesforce/resourceUrl/CCard';
import VisaC from '@salesforce/resourceUrl/VisaCard';
import StripeC from '@salesforce/resourceUrl/StripeImage';
import searchLoan from '@salesforce/apex/LWC_AllLoansCtrl.searchLoan';
import LWCConfigSettingMetadata from '@salesforce/apex/LWC_AllLoansCtrl.LWCConfigSettingMetadata';
import getLeastToCompleteLoanRecord from '@salesforce/apex/LWC_AllLoansCtrl.getLeastToCompleteLoanRecord';
import removeTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.removeTransactionRecord';
import removeTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.removeTransactionRecords';
import recurringRecordCreation from '@salesforce/apex/LWC_AllLoansCtrl.recurringRecordCreation';
import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import updateTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.updateTransactionRecord';
import updateTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.updateTransactionRecords';
import createVDTransaction from '@salesforce/apex/LWC_AllLoansCtrl.createVDTransaction';
import getLenderBalance from '@salesforce/apex/LWC_AllLoansCtrl.getLenderBalance';
import isGuestUser from '@salesforce/apex/LWC_AllLoansCtrl.isGuestUser';
import getCurrentUser from '@salesforce/apex/LWC_AllLoansCtrl.getCurrentUser';
import TopupTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.TopupTransactionRecords';
// import processPayment from '@salesforce/apex/StripePaymentController.processPayment';
import { subscribe, createMessageContext, publish } from 'lightning/messageService';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
import getStripePaymentConfigs from '@salesforce/apex/StripePaymentController.getStripePaymentConfigs';
import processPaymentByCard from '@salesforce/apex/StripePaymentController.processPaymentByCard';
import processPaymentByWallet from '@salesforce/apex/StripePaymentController.processPaymentByWallet';
import processRD from '@salesforce/apex/StripePaymentController.processRD';
//Paypal
import getAccesstoken from '@salesforce/apex/PaypalGetPaymentLink.getAccesstoken';
import getContactForGuest from '@salesforce/apex/PaypalGetPaymentLink.getContactForGuest';
import getPaypalPaymentLink from '@salesforce/apex/PaypalGetPaymentLink.getPaypalPaymentLink';
import capturePayPalOrder from '@salesforce/apex/PaypalGetPaymentLink.capturePayPalOrder';
import processPayPal from '@salesforce/apex/StripePaymentController.processPayPal';
import getAlert from '@salesforce/apex/LWC_AllLoansCtrl.getAlert';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import basePath from '@salesforce/community/basePath';
import updateContactPostalAndMobile from '@salesforce/apex/LWC_AllLoansCtrl.updateContactPostalAndMobile';


const debounce = (func, delay) => {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            func(...args);
        }, delay);
    };
};
export default class Lwr_CareNavBar extends LightningElement {
    canDeleteLoanFromCart = true;
    MGlass = MagGlass;
    UseAvatar = UserIcons;
    shopcart = ShoppingCart;
    changeChampionWindowBody;
    nboxTitle;
    gotoContactUsPage() {
        // window.location.assign('carecontactus');
        location.assign('carecontactus');
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
    ifPaypalPayment() {
        this.transactionIdsCommon();
        this.rdToken = {};
        this.paymentToken = {};
        this.createTokenForRd = false;
        this.cardPayment = false;
        // this.paypalPayment=true;
        this.googlePayment = false;
        this.payByMethod = 'Paypal';
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
                    console.log('conId: ', this.conId)
                })
                .catch(error => {
                    console.log('Guest contact error: ', JSON.stringify(error))
                })
        }
    }
    getPaymentLink() {
        this.canDeleteLoanFromCart = false;
        this.transactionIdsCommon();
        if (this.transactionIds.length > 0) {
            this.isLoading = true;
            //let currentUrl = window.location.href;
            let currentUrl = location.href;
            let urlParts = currentUrl.split('/');
            let index = urlParts.indexOf('s');
            let desiredUrl;
            if (index !== -1) {
                desiredUrl = urlParts.slice(0, index + 1).join('/');
            } else {
                console.log('Segment not found in URL');
            }
            let successPageUrl = basePath + '/careviewallloans?carecart=true&CartModules=true&OpenThankyouPageWithNavBar=true&accesstoken=' + this.accesstoken + '&usedLenderBalance=' + this.usedLenderBalance + '&email=' + this.lenderEmail + '&name=' + this.lenderName.replace(/\s/g, "_");
            let returnPageUrl = basePath + '/careviewallloans?carecart=true&CartModules=true';

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
                        //  window.location.assign(this.urlForPayment);
                        location.assign(this.urlForPayment);
                    }
                    console.log('urlForPayment: ' + this.urlForPayment);
                })
                .catch(error => {
                    console.log('paymentDetail: ' + JSON.stringify(error));
                })
        }
        else {
            this.noItemsInCart = true;
        }
    }
    //Paypal ends here
    newMobilePhone=''
    newMailingPostCode=''
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
    noTermsAndCondition=true;
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
        this.amounttocart = (this.loanidfromparent ? this.loanidfromparent.length : 0) +
            (this.changeChampionTemplate == true ? 1 : 0) +
            (this.LenderTopup == true ? 1 : 0) +
            (this.voluntaryDonation == true ? 1 : 0);
        return this.amounttocart;
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
        let amt = currentCartItemsTotalAmount + this.voluntaryDonation == true ? (Number(currentCartItemsTotalAmount * this.donationAmount) / 100) : 0 +
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
            console.log('other rd amount ', event.target.value)
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
        localStorage.setItem('isCC', true);
        console.log('after calling other charges ')
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
            console.log('Publish 3');
            publish(this.context, CARTMC, message3);
        }
        const message = {
            messageToSend: 'BecomeChampionAddToCart'
        };
        console.log('Publish1');
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
            this.subscribeCCCurrency(0, this.firstAmount);

        } catch (er) {
            console.log('eror from try catch rd ', er)
        }
        this.rdAmount = this.rdData['npe03__Amount__c'];
        this.errorOnRDAmountNull = false;
        this.calculateTotalSelectedAmount();
        localStorage.setItem('SelectedCCAmount', 0);
        localStorage.setItem('isCC', true);
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
        localStorage.setItem('SelectedCCAmount', 0);
        localStorage.setItem('isCC', true);
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
        localStorage.setItem('SelectedCCAmount', 0);
        localStorage.setItem('isCC', true);
    }
    closeVoluntaryDonation() {
        removeTransactionRecord({ idToRemove: this.pageData['Id'] })
            .then(result => {
                localStorage.setItem('isVoluntary', false);
                localStorage.setItem('defaultDonationPercentage', null);
                this.pageData['Id'] = '';
                localStorage.setItem('vdAmount', 0);
                this.voluntaryDonation = false;
                this.voluntaryDonationClosed = true;
                this.calculateTotalSelectedAmount();
                this.donationAmount = 0;
                this.testTotal = parseFloat(this.testTotal.toFixed(2));
            })
            .catch(error => {
                console.log('error while deleting vd closeVoluntaryDonation', JSON.stringify(error))
            })
    }
    closeLenderTopup() {
        this.LenderTopup = false;
        this.LenderTopupClosed = false;
        this.calculateTotalSelectedAmount();
        this.topUpAmount = 0;
        this.topUpAmount1 = '$' + 0;
        this.testTotal = parseFloat(this.testTotal.toFixed(2));
        localStorage.setItem('isTopup', false);
        localStorage.setItem('TopupTransactionId', null);
        localStorage.setItem('topupAmountfromStorage', 0);
        if (this.TopupTransactionId != '' || this.TopupTransactionId != null || this.TopupTransactionId != undefined) {
            removeTransactionRecord({ idToRemove: this.TopupTransactionId })
                .then(result => {
                    console.log('result from apex after delete topup ', JSON.stringify(result))
                    this.TopupTransactionId = null;
                    this.topupData['Id'] = null;
                })
                .catch(error => {
                    console.log('error while deleting ', JSON.stringify(error))
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
    tAmt = 0;
    lenderTopupAmountChangesOn(event) {
        let inputValue = event.target.value;
        inputValue = inputValue.replace(/\D/g, '');
        event.target.value = inputValue;
        this.topUpAmount1 = '$' + event.target.value;
        this.tAmt = Number(event.target.value);
    }
    lenderTopupAmountChanges() {
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
            console.log('537 line ', this.TopupTransactionId.length)
            if (this.TopupTransactionId.length == 15 || this.TopupTransactionId.length == 18) {
                this.topupData['Id'] = this.TopupTransactionId;
            }
            console.log('brfore apex topup ', this.topupData)
            TopupTransactionRecords({ TopupRecord: this.topupData })
                .then(result => {
                    console.log('result from topup ', result);
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
    isChampion = false;
    @wire(getLenderBalance, { conId: '$contactid' })
    wiredLenderBalance(lenderValue) {
        const { data, error } = lenderValue;
        if (data) {
            this.lenderBalanceAmount = data.Lender_Balance__c;
            this.lenderBalanceAmountCart = '$' + parseFloat(this.lenderBalanceAmount).toFixed(2);
            this.noMobilePhone = data.MobilePhone ? true : false;
            this.noPostcode = data.MailingPostalCode ? true : false;
            this.noTermsAndCondition=data.Terms_and_conditions__c ? true : false;
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
                && this.defaultDonationPercentage != '15' && this.defaultDonationPercentage != '25' && this.defaultDonationPercentage != '5') {
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
    }
    rendered = false;
    checkPreviousChangeChampion() {
        setTimeout(() => {
            if (localStorage.getItem('isCC') == 'true' || localStorage.getItem('isCC') == true) {
                this.changeChampionTemplate = true;
                console.log('796 ')
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
                    this.timerLoading = false;
                    removeTransactionRecord({ idToRemove: this.pageData['Id'] })
                        .then(result => {
                            this.voluntaryDonation = false;
                            localStorage.setItem('isVoluntary', false);
                            localStorage.setItem('timerLoading', false);
                            localStorage.setItem('vdId', null);
                            localStorage.setItem('vdAmount', 0);
                            this.pageData['Id'] = null;
                            localStorage.setItem('vdId', null);
                        })
                        .catch(error => {
                            console.log('error while deleting ', JSON.stringify(error))
                        })

                }

                this.publishMC(lId);
                this.createDonationTransRecord();
                if (this.loanidfromparent.length == 0) {
                    this.timerLoading = false;
                }
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
                            OldFunded: loan.Funded__c,
                            Funded: loan.Funded__c + result.Amount__c,
                            Funded__c: result.Amount__c,
                            selectedAmount: result.Amount__c,
                            progressBar: ((loan.Funded__c + result.Amount__c) / loan.Published_Amount_AUD__c) * 100,
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
        if (val != 'Other' && Number(val) != 0) {
            this.otherPercentage = false;
            this.defaultDonationPercentageValue = event.detail.value;
            this.defaultDonationPercentage = Number(event.detail.value);
            localStorage.setItem('defaultDonationPercentage', this.defaultDonationPercentage);
            this.donationAmount = Number(event.detail.value);
            this.createDonationTransRecord();
        }
        else if (Number(val) == 0) {
            this.otherPercentage = false;
            this.errorMessage = false;
            this.defaultDonationPercentageValue = event.detail.value;
            this.defaultDonationPercentage = Number(event.detail.value);
            localStorage.setItem('defaultDonationPercentage', this.defaultDonationPercentage);
            this.donationAmount = Number(event.detail.value);
            if (this.pageData['Id'] != null) {
                removeTransactionRecord({ idToRemove: this.pageData['Id'] })
                    .then(result => {
                        console.log('VoluntaryDonationChange ', result);
                        localStorage.setItem('vdId', null);
                        this.pageData['Id'] = null;
                        localStorage.setItem('vdAmount', 0);
                        this.vdAmount = 0;
                        this.calculateTotalSelectedAmount();
                    })
                    .catch(error => {
                        console.log('error while deleting vd VoluntaryDonationChange ', JSON.stringify(error))
                    })
            }
            this.calculateTotalSelectedAmount();
            this.pageData['Id'] = '';
            localStorage.setItem('vdId', null);
        }
        else if (val == 'Other') {
            this.otherPercentage = true;
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
        this.pageData['Lender__c'] = this.contactid;
        this.pageData['Amount__c'] = (currentCartItemsTotalAmount) * Number(this.defaultDonationPercentage) / 100;
        this.pageData['Type__c'] = 'Donation';
        console.log('this page Data ', JSON.stringify(this.pageData));
        if (this.pageData['Amount__c'] > 0 && this.voluntaryDonation == true) {
            createVDTransaction({ rec: this.pageData })
                .then(result => {
                    if (result.Id.length >= 15 || result.Id.length >= 18) {
                        localStorage.setItem('vdId', result.Id);
                        this.pageData['Id'] = result.Id;
                        this.vdAmount = result.Amount__c;
                        localStorage.setItem('vdAmount', Number(this.vdAmount));
                        this.calculateTotalSelectedAmount();
                    }
                })
                .catch(error => {
                    console.log('error creating voluntary donation transaction record ', JSON.stringify(error));
                    localStorage.setItem('vdId', null);
                    this.pageData['Id'] = null;
                })
        }
        else if (this.pageData['Amount__c'] == 0 && this.voluntaryDonation == true)
            if (this.pageData['Id'] != null) {
                removeTransactionRecord({ idToRemove: this.pageData['Id'] })
                    .then(result => {
                        console.log('createDonationTransRecord ', result);
                        localStorage.setItem('vdId', null);
                        this.pageData['Id'] = null;
                        localStorage.setItem('vdAmount', 0);
                        this.vdAmount = 0;
                        this.calculateTotalSelectedAmount();
                    })
                    .catch(error => {
                        console.log('error while deleting vd createDonationTransRecord', JSON.stringify(error))
                    })
            }
        this.calculateTotalSelectedAmount();
    }
    endsWith5Or0(number) {
        return number % 10 === 0 || number % 10 === 5;
    }
    otherPercentageValue;
    otherPercentageChangeOn(event) {
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

        if (this.otherPercentageValue > 0 && this.otherPercentageValue <= 100) {
            this.errorMessage = false;
            this.createDonationTransRecord();
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
                        console.log('other % change ', result);
                        this.pageData['Id'] = null;
                        this.vdAmount = 0;
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
            this.showErrorMessage = true;
            return;
        }
        searchLoan({ searchKey: this.searchTerm })
            .then(result => {
                this.apiLoanResults = result;
                if (this.apiLoanResults) {
                    location.assign('caresearchresults?searchTerm=' + this.searchTerm);

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
        this.canDeleteLoanFromCart = false;
        this.processingAmount = parseFloat(this.testTotal).toFixed(2);
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
            if (this.showGooglePay) {
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
            if (this.noMobilePhone && this.noPostcode && this.noTermsAndCondition ) {
                if (this.showGooglePay) {
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
        // let currentUrl = window.location.href;
        let currentUrl = location.href;
        let urlParts = currentUrl.split('/');
        let index = urlParts.indexOf('s');
        let desiredUrl;
        if (index !== -1) {
            desiredUrl = urlParts.slice(0, index + 1).join('/');
        } else {
            console.log('Segment not found in URL');
        }
        location.assign(basePath + '/caredashboard');
    }
    OpenHomePage() {
        location.assign('carebecomechangechampion');
    }
    handleCheckoutGuest() {
        this.guestCheckout = true;
        this.checkOutasGuest = false;
        var isCC = localStorage.getItem('isCC')
        console.log('IISSL:', isCC, this.changeChampionTemplate);
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

        console.log('transactionIds from now common ', this.transactionIds + ' length ' + this.transactionIds.length);
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
    }
    gotoThankYouPayNow() {
        this.paymentError = '';
        this.isLoading = true;
        this.payButtonDisabled = true;
        this.canDeleteLoanFromCart = false;
        this.transactionIdsCommon();
        this.payableFinalTransactionAmount();
        //this.addTrackingCodeStackadapt();
        //this.addTrackingCodeGTM();
        if (this.transactionIds.length > 0 || this.rdAmount > 0) {
            this.isLoading = true;    
            if (this.finalTransactionAmount === 0 && this.lenderBalanceSelected) {
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
        else {
            this.noItemsInCart = true;
            this.isLoading = false;
        }
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

    //this.finalTransactionAmount = 0;
    //this.usedLenderBalance = this.loanAndRdAmount;
    addTrackingCode(){
        let revenu = (this.finalTransactionAmount===0) ? this.loanAndRdAmount : this.finalTransactionAmount;
        let gtmId = crypto.randomUUID();
        console.log("Stackadapt:tracking ["+revenu+"]");
        !function (s, a, e, v, n, t, z) { if (s.saq) return; n = s.saq = function () { n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments) }; if (!s._saq) s._saq = n; n.push = n; n.loaded = !0; n.version = '1.0'; n.queue = []; t = a.createElement(e); t.async = !0; t.src = v; z = a.getElementsByTagName(e)[0]; z.parentNode.insertBefore(t, z) }(window, document, 'script', 'https://tags.srv.stackadapt.com/events.js'); saq('conv', 'Ite9wUldEIaLakWPNRBk9f', { 'revenue': revenu });
        console.log("gtm-tracking: <"+revenu+"> gtmId: <"+gtmId+">");
        this.dispatchEvent(
            new CustomEvent(
                    'gtmTrackPurchase',
                    {bubbles: true, composed: true, detail: {revenu: revenu, gtmTransactionId: gtmId}}
                )
            );
    }    
    noItemsInCart = false;
    setThankYouPayNow(data) {
        this.isLoading = true;
        if (data.isError) {
            this.paymentError = data.message;
            this.isLoading = false;
        } else {
            this.OpenThankyouPageWithNavBar = true;
            this.addTrackingCode();
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
            localStorage.setItem('rdAmt', 0);
            this.canMoveFromSixthPage = false;
            this.isLoading = false;
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
        console.log('gotoSecondPage')
    }

    setPaymentMethods() {
        this.haveLenderBalance = false;
        this.LenderbalanceChecked = false;
        this.lenderBalanceSelected = false;
        if (this.testTotal > 0) {
            this.amountZero = false;
        }
        console.log('')
        if (this.loanidfromparent.length > 0) {
            this.haveLoaninCart = true;
        }
        console.log('this.isGuest 1897 line ', this.isGuest);
        if (this.loanidfromparent.length < 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;
            console.log('1905 line ')
        }
        else if (this.loanidfromparent.length < 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
            console.log('1914 line ')
        }
        else if (this.loanidfromparent.length < 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
            console.log('1923 line ')
        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
                console.log('1929 line ')
            }
            console.log('1796');
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
                console.log('1943 line ')
            }
            console.log('1806')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == false
            && this.changeChampionTemplate == false) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
                console.log('1956 line ')
            }
            console.log('1816')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length > 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            if (this.isGuest == false && this.lenderBalanceAmount > 0) {
                this.haveLenderBalance = true;
                console.log('1970 line ')
            }
            console.log('1816')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;

        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == true
            && this.changeChampionTemplate == false) {
            this.haveLenderBalance = false;
            console.log('1984 line ')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;

        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == false
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            console.log('1993 line ')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        else if (this.loanidfromparent.length == 0 && this.LenderTopup == true
            && this.changeChampionTemplate == true) {
            this.haveLenderBalance = false;
            console.log('2002 line ')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = false;
            this.showApplePay = false;
            this.showGooglePay = false;
        }
        console.log('1845');
        if (this.isGuest == true) {
            this.haveLenderBalance = false;
            console.log('12011 line ')
            this.showCreditCard = this.isshowCreditCard;
            this.showPaypal = this.isshowPaypal;
            this.showApplePay = this.isshowApplePay;
            this.showGooglePay = this.isshowGooglePay;
            console.log('1862')
        }
    }
    //It will take us to 3rd page
    processingAmount = 0;
    errorOnRDAmountNull = false;
    gotoSecondPage() {
        this.noItemsInCart = false;
        this.setPaymentMethods();
        this.processingAmount = this.testTotal;
        let lvdamt = this.loanAndRdAmount;

        let vdAmount = localStorage.getItem('vdAmount');
        // Woopra Tracking event: https://trailhead.salesforce.com/trailblazer-community/feed/0D54V00007T4E69SAF
        console.log('lenderEmail: '+ this.lenderEmail);
        if (this.lenderEmail)
        {
            localStorage.setItem('useremail',this.lenderEmail);
            this.dispatchEvent(
                new CustomEvent(
                    'woopraIdentifyEmail',
                    {bubbles: true, composed: true, detail: this.lenderEmail}
                )
            );
        };
        console.log('vdAmount from 1726 ', vdAmount)
        if (Number(vdAmount) >= 0) {
            this.vdAmount = vdAmount;
        }
        console.log('RD id ', this.rdData['Id'], ' ', (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0))
        console.log('topup ', this.topUpAmount, ' ', this.TopupTransactionId);
        console.log('Voluntary donation trans id ', 'Amount ', this.vdAmount, this.pageData['Id'] ? this.pageData['Id'] : 0);

        if (this.LenderTopup == true && this.topUpAmount < 2) {
            this.errorMessageTopup = true;
            console.log('1592 line')
        }
        else {
            this.errorMessageTopup = false;
            console.log('1596 line')
        }
        console.log('error messages--> ' + this.errorMessageTopup + ' ' + this.errorMessage + ' ' + this.errorOnRDAmountNull)
        if (this.loanidfromparent != undefined && this.testTotal >= 100 && this.defaultDonationPercentage >= 15 &&
            this.loanidfromparent.length >= 2 && this.voluntaryDonationClosed == false
            && this.changeChampionTemplate == false && this.errorMessageTopup == false
            && this.errorMessageTopupkKYCPending == false && this.errorMessageTopupNull == false
            && this.errorOnRDAmount == false && this.errorMessage == false
            && this.isGuest == false && this.isChampion == false
        ) {
            this.OpenCCRedirectMessage = true;
            this.CartLendChangeChampion = false;
            this.CartChangeChampion = false;
            this.amountZero = false;
        }
        else if (this.testTotal == 0) {
            this.amountZero = true;
        }

        else if (this.errorMessageTopup == false && this.errorMessage == false
            && ((this.changeChampionTemplate == false && this.errorOnRDAmountNull == false)
                || (this.changeChampionTemplate == true && this.errorOnRDAmountNull == false))) {
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

            if (this.showGooglePay) {
                this.isLoading = true;
                this.payableFinalTransactionAmount();
            }
            this.thirdPage = false;
            this.thirdPage = true;
            this.currentStep = "3";
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
        console.log('CCTT:', this.changeChampionTemplate);
        if (this.termCheck == false || this.guestEmail == undefined || this.guestEmail == '' || this.guestFName == '' || this.guestLName == '' || this.guestFName == undefined || this.guestLName == undefined) {
            this.showGuestError = true;
        } else {
            var isCC = localStorage.getItem('isCC')
            if (isCC != undefined && isCC != 'undefined') {
                this.checkPreviousChangeChampion();
            }
            if (this.changeChampionTemplate == undefined || this.changeChampionTemplate == 'undefined') {
                this.changeChampionTemplate = false;
                console.log('2182');
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
            this.googlePayment = false;
            this.payByMethod = 'Card';
        }
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
        if (this.noPostcode && this.noMobilePhone && this.noTermsAndCondition) {
            this.fifthPage = true;
            this.currentStep = "5";
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
    }
    gotoFifthPage(){
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
        //console.log('Nav Bar');
        var eventValues = message ? JSON.stringify(message, null, '\t') : undefined;
        if (eventValues != undefined) {
            eventValues = JSON.parse(eventValues);
            console.log(eventValues.messageToSend);
            console.log(eventValues.currentRecordId);
            console.log(eventValues.amountAddedToCart);
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
                console.log('2053 this.changeChampionTemplate = true; ')
                this.becomeChangeChampionActivate(eventValues.currentRecordId);
            } 
        }
       
    }
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

        console.log('before this.rdData[npe03__Amount__c] ', this.rdData['npe03__Amount__c'])
        console.log('before this.currentCartItemsTotalAmount ', currentCartItemsTotalAmount)
        console.log('before this.topUpAmount ', this.topUpAmount)
        console.log('before this.donationAmount ', this.donationAmount)
        console.log('before creating rd record 35 ', JSON.stringify(this.rdData));

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

        const encodedValue1 = this.getUrlParamValue(location.href, tempId1);

        if (encodedValue1) {
            this.token = decodeURIComponent(encodedValue1);
        }
        const tempId2 = 'CartModules';

        const encodedValue2 = this.getUrlParamValue(location.href, tempId2);

        if (encodedValue2) {
            this.CartModules = decodeURIComponent(encodedValue2);
        }
        const tempIdcart = 'carecart';

        const encodedValueCart = this.getUrlParamValue(location.href, tempIdcart);

        if (encodedValueCart) {
            this.carecart = decodeURIComponent(encodedValueCart);
        }

        const tempId4 = 'OpenThankyouPageWithNavBar';

        const encodedValue4 = this.getUrlParamValue(location.href, tempId4);

        if (encodedValue4) {
            this.OpenThankyouPageWithNavBar = decodeURIComponent(encodedValue4);
            this.isLoading = this.OpenThankyouPageWithNavBar;
        }
        const tempId5 = 'usedLenderBalance';

        const encodedValue5 = this.getUrlParamValue(location.href, tempId5);

        if (encodedValue5) {
            this.usedLenderBalanceToSend = decodeURIComponent(encodedValue5);
            console.log('usedLenderBalanceToSend: ' + this.usedLenderBalanceToSend);
        }
        const tempId3 = 'accesstoken';

        const encodedValue3 = this.getUrlParamValue(location.href, tempId3);

        if (encodedValue3) {
            this.accesstoken = decodeURIComponent(encodedValue3);

        }
        let lenderEmail = '';

        const encodedEmail = this.getUrlParamValue(location.href, 'email');

        if (encodedEmail) {
            lenderEmail = decodeURIComponent(encodedEmail);
        }
        let lname = '';

        const encodedName = this.getUrlParamValue(location.href, 'name');

        if (encodedName) {
            lname = decodeURIComponent(encodedName.replace(/_/g, ' '));
        }

        let transactionIds = [];
        var paymentArrays = localStorage.getItem('myArray');
        console.log('paymentArrays: ' + paymentArrays);
        console.log('transactionIds: before loans ' + transactionIds);
        if (paymentArrays != undefined && paymentArrays != '' && paymentArrays != 'undefined') {
            paymentArrays = JSON.parse(paymentArrays);
            transactionIds = paymentArrays.map(item => item.TransactionId).filter(Boolean);
            console.log('paymentArrays: transactionIds ', transactionIds)
        }
        if (this.TopupTransactionId != null) {
            transactionIds.push(this.TopupTransactionId);
        }
        let vdtranId = localStorage.getItem('vdId');
        if (vdtranId != '' && vdtranId != null && vdtranId != undefined && vdtranId != 'null'
            && vdtranId.length >= 15 && vdtranId.length <= 18) {
            transactionIds.push(vdtranId);
        }
        console.log('ConnectedIds: after loans ' + transactionIds);
        if (this.accesstoken != null && this.token != null && transactionIds != null) {
            capturePayPalOrder({ accesstoken: this.accesstoken, orderId: this.token })
                .then(result => {
                    console.log('OrderStatus: ', JSON.stringify(result))
                    if (result != null || result.length != 0) {
                        this.paymentDetailPaypal = {
                            object: 'paypal',
                            id: result.id
                        }
                        console.log('paymentDetailPaypal: ' + JSON.stringify(this.paymentDetailPaypal));
                        let request = {
                            contactId: result.referenceId,
                            paymentResponse: JSON.stringify(this.paymentDetailPaypal),
                            transactionsIds: transactionIds.filter(id => id !== null && id !== undefined && id != 'null' && id !== ''),
                            usedLenderBalance: this.usedLenderBalanceToSend,
                            email: lenderEmail,
                            fullLenderName: lname //this.lenderName ? this.lenderName : this.guestFName + ' ' + this.guestLName
                        };
                        console.log('request: ' + JSON.stringify(request));
                        processPayPal(request)
                            .then(result => {
                                console.log('SuccessPaypal: ', JSON.stringify(result))
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
                                localStorage.setItem('rdAmt', 0);
                                console.log('after delete all the loans', this.loanidfromparent)
                                this.isLoading = false;
                                this.canMoveFromSixthPage = false;
                            })
                            .catch(error => {
                                console.log('RecordUpdattion error: ', JSON.stringify(error))
                            })
                    }
                })
                .catch(error => {
                    this.paymentError = this.reduceErrors(error) + ' Please select the payment method again';
                    console.log('OrderStatus error: ', JSON.stringify(error))
                    this.isLoading = false;
                })
        }
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
        console.log('vdamount from handlevd ', localStorage.getItem('vdAmount'));
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
            console.log('2527');
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
            console.log('from cc local rdAmount this.rdAmount ', this.rdAmount)
        }
    }
    handleTopup() {
        let isTopup = localStorage.getItem('isTopup');
        console.log('isTopup from connected ', isTopup);
        this.TopupTransactionId = localStorage.getItem('TopupTransactionId');
        console.log('TopupTransactionId from connected ', this.TopupTransactionId);
        const topupAmountfromStorage = localStorage.getItem('topupAmountfromStorage');
        console.log('topupAmountfromStorage from connected ', topupAmountfromStorage);
        if (isTopup == 'true') {
            if (this.TopupTransactionId != null && this.TopupTransactionId != 'null') {
                this.topupData['Id'] = this.TopupTransactionId;
            }
            else {
                this.topupData['Id'] = null;
            }

            this.LenderTopup = true;
            this.topUpAmount = Number(topupAmountfromStorage);
            this.topUpAmount1 = '$' + this.topUpAmount;
            this.calculateTotalSelectedAmount();
        }
        this.calculateTotalSelectedAmount();

    }
    contactChampion = false;
    currentUser() {
        getCurrentUser()
            .then(result => {
                console.log('logged in user ', result.ContactId)
                this.contactid = result.ContactId;
                this.contactChampion = result.Contact != undefined ? result.Contact.Champion__c : '';
                console.log('1535 navbar page ', this.contactid);
            })
            .catch(error => {
                console.log('error currentUser ', JSON.stringify(error))
            })
    }
    checkGuestUser() {
        isGuestUser().then(isGuestUser => {
            console.log('isGuestUser:--> ', isGuestUser);
            this.OpenCCRedirectMessage = false;
            this.checkOutasGuest = false;
            this.createAccount = false;
            this.signIn = false;
            this.firstPage = false;
            this.amountZero = false;
            this.isGuest = isGuestUser;
            console.log('this.isGuest--> ', this.isGuest)
            if (isGuestUser == true || isGuestUser == undefined || isGuestUser == null) {
                console.log('Inside', isGuestUser == true, isGuestUser == undefined, isGuestUser == null);
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
                console.log('2412')
            } else {
                console.log('Inside3');
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
            console.log('before updating ', this.idsToUpdate, 'contact id ', this.contactid)
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
        if (fromCart == 'true' || fromCart == true) {
            this.CartModules = true;
            this.carecart = true;
            localStorage.setItem('fromCart', false);
        }
        var myA = localStorage.getItem('myArray');
        console.log('myA --> ', myA, this.loanidfromparent)
        if (myA != undefined && myA != '' && myA != 'undefined') {
            this.storedArray = JSON.parse(localStorage.getItem('myArray'));
        }

        if (this.storedArray) {
            this.loanidfromparent = this.storedArray;
            console.log('this.loanidfromparent ', JSON.stringify(this.loanidfromparent))
            let istimerLoading = localStorage.getItem('timerLoading');
            console.log('istimerLoading ', istimerLoading);
            if (istimerLoading == 'true') {
                if (this.loanidfromparent.length > 0) {
                    this.timerLoading = true;
                }
            }
        } else {
            console.log('Array not found in local storage');
        }
        var isCC = localStorage.getItem('isCC')
        console.log('CCCC:', isCC);
        if (isCC != undefined && isCC != 'undefined' && isCC == 'true') {
            this.changeChampionTemplate = true;
            console.log('CCCC2:', isCC);
        } else {
            this.changeChampionTemplate = false;
            console.log('2690');
        }
        if (this.loanidfromparent != undefined && this.loanidfromparent.length > 0 || this.changeChampionTemplate == true) {
            this.calculateTotalSelectedAmount();
            setTimeout(() => {
                this.updateTransactions();
            }, 5000)

        }
        this.debounceTimeout = null;
        //const currentPageUrl = window.location.href;
        const currentPageUrl = location.href;

        //  var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s') + 3);
        var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/') + 3);

        var createAcc = currentPageUrl2.substring(0, currentPageUrl2.length - 2) + 'secur/CommunitiesSelfRegUi';
        this.navComponentLinks = {
            'HomePage': '',
            'AboutUs': 'aboutus',
            'login': 'login',
            'ContactUs': 'carecontactus',
            'ViewAllLoans': 'careviewallloans',
            'BecomeChangeChampion': 'carebecomechangechampion',
            'OurImpact': 'ourimpact',
            'CareHelpcentre': 'carehelpcentre',
            'CareDashboard': 'login',
            'login': 'login',
            'createAccount': createAcc,
            'cd': 'caredashboard'
        };
        //if (window.location.href == this.navComponentLinks['cd']) {
        if (location.href == this.navComponentLinks['cd']) {
            var sessionVal = sessionStorage.getItem('UniqueValue');
            console.log('Dash:', sessionVal);
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
            console.log('in care nave bar viewwww')
            
            //this.isVisible = false;
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
        console.log('lengthofparent' + this.loanidfromparent.length);
        if (this.loanidfromparent.length > 0) {
            this.timerLoading = true;
            console.log('timer')
            console.log(`${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`)
            return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        }
        else {
            this.timerLoading = false;
            return 0;
        }

    }
    @api startTimer1() {
        this.isTimerStarts = false;
        this.setTime = 0;
        this.startTimer(2700);
    }
    @api isTimerStarts = false;
    @api
    startTimer(duration) {
        const endTime = new Date().getTime() + duration * 1000;
        this.timerstopped = false;

        localStorage.setItem('timerEndTime', endTime);


        if (this.timerInterval) {
            clearInterval(this.timerInterval);
        }

        this.timerInterval = setInterval(() => {
            const currentTime = new Date().getTime();
            const timeRemaining = Math.max(0, endTime - currentTime) / 1000;

            this.setTime = Math.ceil(timeRemaining);
            localStorage.setItem('setTime', this.setTime);

            if (this.setTime == 0 && this.timerstopped == false) {
                this.stopTimer();
                this.timerstopped = true;
            }
        }, 1000);
    }
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
        this.setTime = 0
        localStorage.setItem('setTime', 0);
        this.timerInterval = null;
        this.totalCartAmount = 0;
        this.clearArray();
        const deleteAllFromParentComponent = new CustomEvent('deleteallloans', {
            detail: this.loanidfromparent

        });
        if (this.loanidfromparent.length > 0) {
            this.dispatchEvent(deleteAllFromParentComponent);
            console.log('deleting the mass loan itesm ')
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
        if (this.idsToDelete.length != 0 && this.canDeleteLoanFromCart == true) {
            removeTransactionRecords({ recordsToDelete: this.idsToDelete })
                .then(result => {
                    this.loanidfromparent = [];
                    localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
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
        this.rdData['npe03__Amount__c'] = 0;
        this.donationAmount = '15';
        this.isAdded = false;
        localStorage.setItem('isTopup', false);
        localStorage.setItem('TopupTransactionId', null);
        localStorage.setItem('topupAmountfromStorage', 0);
        localStorage.setItem('isVoluntary', false);
        localStorage.setItem('defaultDonationPercentage', null);
        localStorage.setItem('vdId', null);
        this.voluntaryDonation = false;
        this.TopupTransactionId = null;
        this.pageData['Id'] = null;
        localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
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
        localStorage.setItem('fromCart', true);
        var val = event.target.dataset.value;
        sessionStorage.setItem('UniqueValue', '1234');
        this.isGuest = false;
        if (val == 'SignIn') {
            location.href = this.navComponentLinks.login;
        } else if (val == 'Create') {
            location.href = this.navComponentLinks.createAccount;
        } else if (val == 'gmail') {
            // window.location.href = 'https://accounts.google.com/o/oauth2/auth/oauthchooseaccount?response_type=code&client_id=95925662322-jroo0m34qta6c7f2tkfhadkes4l9rr79.apps.googleusercontent.com&redirect_uri=https%3A%2F%2Ftest.salesforce.com%2Fservices%2Fauthglobalcallback&scope=email%20openid%20profile&state=CAAAAYrP1B9YMDAwMDAwMDAwMDAwMDAwAAAA9uW564tEF1Wcwta7K2TM42GBb_ytLK6d9ixGtFYTD8DIvZ1RVizN3m0wZFPFB6fxR8EBRWRjO121gzFss_exP3gOf3uuZyv_se-ofWObCDD95hWpNjkE3oc_vXwiMdDgXiIYw3TacXxyovle9AhIzVIzXIyr15XeYPOtRC5htnm7zckUE4EBRyxSav9_q8UnzBxTiTWYfwbKOXhfNdN-rVYOIr6-ilJbr9gKOlkOY8WMx1HhJkO_0iPDmidJz24dXVWLqmPJ1Dd-6KnE36_V29snQpajucGB0bhphR2VDSzA9mZRVid7Zf0K8iBPrbMo6qn2un4HxflGkyma71ME27HNjElr506e-F9XGhrG7Prdyu5bWuFptFy6WNH84rVRlgsVtoGwxAp6Vtxa7Sv5-79OYEEQnmhrLlm0hbxnQzf6tQEW2mTLT83NNbZVa9QzA_2lccsXRi3EH2Jw4xkKd-6Y4Oxh-Ibt30KL9TUjDc0HWu6M67ZzZP3HaMCTQ1Xx7U_BUQ6SANMfXVHUki2d4zIukUNM8YFJVHZWuVoaud4fOxvCp25n85JlFaG8-_5gbg%3D%3D&service=lso&o2v=1&theme=glif&flowName=GeneralOAuthFlow';
        } else if (val == 'facebook') {
            // window.location.href = '';
            location.href = '';
        } else if (val == 'Forgot') {
            location.href = this.navComponentLinks.login + '/ForgotPassword'
        }
    }
    handleContinueAsGuest() {
        this.checkOutasGuest = true;
    }
    handleInputChangeGuest(event) {
        var fieldName = event.target.dataset.value;
        var value = event.target.value;
        console.log('fName:', fieldName, value);
        if (fieldName == 'FirstName') {
            this.guestFName = value;
        } else if (fieldName == 'LastName') {
            this.guestLName = value;
            this.lenderName = this.guestFName + ' ' + this.guestLName;
        } else if (fieldName == 'Email') {
            this.guestEmail = value;
            this.lenderEmail = this.guestEmail;
        } else if (fieldName == 'Terms') {
            this.termCheck = event.target.checked;
            console.log(this.termCheck);
        }
    }
    openLoginOrDashboard() {
        if (this.contactid != null) {
            const newUrldash = basePath + '/' + 'caredashboard';
            location.assign(newUrldash);
        } else {
            const newUrllogin = basePath + '/' + 'login/';
            location.assign(newUrllogin);
        }
    }
    isRemainingBalance = false;
    LenderbalanceChecked = false;
    lenderBalanceSelected = false;
    isTopupAdded = false;
    onUseLenderbalance(event) {
        console.log('As-->');
        console.log('this.LoanAndRDAmount');
        console.log(this.LoanAndRDAmount);
        console.log('As-->');
        console.log('this.lenderBalanceAmount');
        console.log(this.lenderBalanceAmount);
        console.log('As-->');
        console.log('this.LenderTopup');
        console.log(this.LenderTopup);
        console.log('As-->');
        console.log('this.changeChampionTemplate');
        console.log(this.changeChampionTemplate);
        if (this.showGooglePay) {
            this.isLoading = true;
        }
        console.log('checked--> ', event.target.checked);
        this.lenderBalanceSelected = event.target.checked;
        if (event.target.checked == true) {
            if (this.LoanAndRDAmount <= this.lenderBalanceAmount && this.LenderTopup == false
                && this.changeChampionTemplate == false) {
                this.showCreditCard = false;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = true;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                console.log('1st if')
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == false
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                console.log('2nd if')
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == true
                && this.changeChampionTemplate == true) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = false;
                this.showApplePay = false;
                this.showGooglePay = false;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                console.log('3rd if')
            }
            else if (this.LoanAndRDAmount < this.lenderBalanceAmount && this.LenderTopup == true
                && this.changeChampionTemplate == false) {
                this.showCreditCard = this.isshowCreditCard;
                this.showPaypal = this.isshowPaypal;
                this.showApplePay = this.isshowApplePay;
                this.showGooglePay = this.isshowGooglePay;
                this.LenderbalanceChecked = false;
                this.processingAmount = parseFloat(this.topUpAmount + (this.rdData['npe03__Amount__c'] ? Number(this.rdData['npe03__Amount__c']) : 0)).toFixed(2);
                console.log('4th if')
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

                    console.log('5th if')

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
                    console.log('6th if')

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
                    console.log('7th if')

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
                    console.log('8th if')
            }
        }
        else if (event.target.checked == false) {
            this.processingAmount = this.testTotal;
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
            console.log('8th if')
        }
        this.setRemainingBalance();
        console.log(' this.processingAmount');
        console.log(this.processingAmount)
    }
    setRemainingBalance() {
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
            }
        }
        else if (this.lenderBalanceSelected == false) {
            this.isRemainingBalance = false;
            this.remainingBalanceAmount = 0;
        }
        this.payableFinalTransactionAmount();
        if (this.showGooglePay && this.finalTransactionAmount > 0) {
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
        let vdAmount = localStorage.getItem('vdAmount');
        console.log('vdAmount from 2941 ', vdAmount)
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
        this.LoanAndRDAmount = parseFloat(amt.toFixed(2));
        return parseFloat(amt.toFixed(2));
    }
    RDAmount = 0;
    rdAmount = 0;
    closechangeChampionTemplate() {
        console.log('2726')
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
    gotoHelpCenter() {
        //window.location.assign('carehelpcentre')
        location.assign('carehelpcentre')
    }
    handleMobileChange(event) {
        this.newMobilePhone = event.target.value
    }
    handlePostcodeChange(event) {
        this.newMailingPostCode = event.target.value
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
    handleUpdateContact() {

        if (this.newMobilePhone || this.newMailingPostCode || this.termsAndConditionValue) {

            updateContactPostalAndMobile({
                contactId: this.contactid,
                mobilePhone: this.newMobilePhone,
                mailingPostalCode: this.newMailingPostCode,
                termsAndConditions: this.termsAndConditionValue
            })
                .then(result => {
                    console.log('Apex Result: ', result);
                })
                .catch(error => {
                    console.error('Apex Error: ', error);
                });
        }

    }
}