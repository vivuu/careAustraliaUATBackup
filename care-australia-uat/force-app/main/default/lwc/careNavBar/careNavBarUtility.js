// careNavBarUtility.js
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

// apex classes
import searchLoan from '@salesforce/apex/LWC_AllLoansCtrl.searchLoan';
import removeTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.removeTransactionRecord';
import removeTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.removeTransactionRecords';
import removeZeroAmountTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.removeZeroAmountTransactionRecord';
import recurringRecordCreation from '@salesforce/apex/LWC_AllLoansCtrl.recurringRecordCreation';
import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import updateTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.updateTransactionRecord';
import updateTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.updateTransactionRecords';
import createVDTransaction from '@salesforce/apex/LWC_AllLoansCtrl.createVDTransaction';
import isGuestUser from '@salesforce/apex/LWC_AllLoansCtrl.isGuestUser';
import getCurrentUser from '@salesforce/apex/LWC_AllLoansCtrl.getCurrentUser';
import updateDonationRecord from '@salesforce/apex/LWC_AllLoansCtrl.updateDonationRecord';
import TopupTransactionRecords from '@salesforce/apex/LWC_AllLoansCtrl.TopupTransactionRecords';
import { subscribe, createMessageContext, publish } from 'lightning/messageService';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
import getStripePaymentConfigs from '@salesforce/apex/StripePaymentController.getStripePaymentConfigs';
import processPaymentByCard from '@salesforce/apex/StripePaymentController.processPaymentByCard';
import processPaymentByWallet from '@salesforce/apex/StripePaymentController.processPaymentByWallet';
import processRD from '@salesforce/apex/StripePaymentController.processRD';
import getAccesstoken from '@salesforce/apex/PaypalGetPaymentLink.getAccesstoken';
import getContactForGuest from '@salesforce/apex/PaypalGetPaymentLink.getContactForGuest';
import getPaypalPaymentLink from '@salesforce/apex/PaypalGetPaymentLink.getPaypalPaymentLink';
import capturePayPalOrder from '@salesforce/apex/PaypalGetPaymentLink.capturePayPalOrder';
import processPayPal from '@salesforce/apex/StripePaymentController.processPayPal';
import getAlert from '@salesforce/apex/LWC_AllLoansCtrl.getAlert';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';

export {
    Hamburger,
    MagGlass,
    UserIcons,
    ShoppingCart,
    LendWithCareImages,
    LWCLogo,
    UserSVG,
    FbIcon,
    GooIcon,
    AppIcon,
    AExpress,
    CC,
    VisaC,
    StripeC,
    //apex classes
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
    getContent,
    //LMS
    subscribe,
    createMessageContext,
    publish,
    CARTMC,
};
export function updateTransactionCostIfLenderBalanceEnabled(component) {
    console.log('update_Transaction_Cost_If_LenderBalanceEnabled : ');
    let coverTransactionCost = parseFloat((Number(component.remainingBalanceAmount) * 0.03).toFixed(2));
    if (component.showCoverTransactionCost) {
        component.processingAmount = parseFloat((Number(component.processingAmount) + Number(coverTransactionCost)).toFixed(2));
    }
    console.log('coverTransactionCost : ', coverTransactionCost);
    console.log('processingAmount : ', component.processingAmount);
}

export function updateCartItemsLength(component) {
    let amounttocart = 0;
    if (component.loanidfromparent) amounttocart++;
    if (component.changeChampionTemplate) amounttocart++;
    if (component.LenderTopup) amounttocart++;
    if (component.voluntaryDonation) amounttocart++;
    if (component.showCoverTransactionCost) amounttocart++;
    if (component.lenderBalanceSelected) amounttocart++;
    return amounttocart;
}

export function removeZeroAmountTransaction(component) {
    console.log('removeZeroAmountTransaction : ');
    console.log('pageData id : ',component.pageData['Id']);
    console.log('vdId : ',localStorage.getItem('vdId'));
    try{
        removeZeroAmountTransactionRecord({ transId: component.pageData['Id'] })
        .then(result => {
            localStorage.setItem('isVoluntary', false);
            localStorage.setItem('defaultDonationPercentage', null);
            component.pageData['Id'] = '';
            localStorage.setItem('vdAmount', 0);
            component.voluntaryDonation = false;
            component.voluntaryDonationClosed = true;
            console.log('Zero Amount Transaction is deleted : ',result);
        })
        .catch(error => {
            console.log('error while deleting vd removeZeroAmountTransaction', JSON.stringify(error));
        })
    }
    catch(error){
        console.log('error removeZeroAmountTransaction : ',error);
    }
}

export function updateTransactionCost(component) {
    console.log('updateTransactionCost : ');
    component.coverTransactionCost = parseFloat((Number(component.testTotal) * 0.03).toFixed(2));
    console.log('coverTransactionCost 139 ext js : ', component.coverTransactionCost);
}

// update_Transaction_Cost_If_LenderBalanceEnabled(){ 
//     console.log('update_Transaction_Cost_If_LenderBalanceEnabled : ',);
//     this.coverTransactionCost = (Number(this.remainingBalanceAmount) * 0.03).toFixed(2);
//     if(this.showCoverTransactionCost){
//         this.processingAmount = (Number(this.processingAmount) + Number(this.coverTransactionCost)).toFixed(2);
//     }
// }

// get totalNoOfCartItems() {
//     this.amounttocart = (this.loanidfromparent ? this.loanidfromparent.length : 0) +
//         (this.changeChampionTemplate == true ? 1 : 0) +
//         (this.LenderTopup == true ? 1 : 0) +
//         (this.voluntaryDonation == true ? 1 : 0) +
//         (this.showCoverTransactionCost == true ? 1 : 0);
//     console.log('this.loanidfromparent.length , this.changeChampionTemplate , this.voluntaryDonation ,this.showCoverTransactionCost ,this.amounttocart : ',this.loanidfromparent.length,this.changeChampionTemplate == true, this.voluntaryDonation == true, this.showCoverTransactionCost == true,this.amounttocart);
//     return this.amounttocart;
// }