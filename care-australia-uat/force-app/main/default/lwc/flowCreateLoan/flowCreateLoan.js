import { LightningElement, api, wire, track } from 'lwc';
import createrecords from '@salesforce/apex/LWC_RepaymentScheduleTableFlowAction.createrecords';
import getrepayment from '@salesforce/apex/LWC_RepaymentScheduleTableFlowAction.getrepayment';
import updaterecords from '@salesforce/apex/LWC_RepaymentScheduleTableFlowAction.updaterecords';
import deleterecords from '@salesforce/apex/LWC_RepaymentScheduleTableFlowAction.deleterecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import { refreshApex } from '@salesforce/apex';

export default class FlowCreateLoan extends NavigationMixin(LightningElement) {
    @api Store_CreatedLoanID; // created loan id from flow
    @api recordID;            // updated loan id from flow
    @api countloanterms;
    @api Priorcountloanterms;
    @api LoanPrincipalDisbursed;
    @api LoanDisbursementDate;
    @api LoanSchedule;
    //@api DueDate;
    @api AmountDue;
    @api varLoanName;
    @track newamount;
    @track duedate;
    @track loanterms = [];
    items = [];
    //items1 = [];
    data = [];
    @track loanValues = [];
    dates = [];
    @track iscreateloan = false;
    @track isupdateloan = false;
    repaymentRecords;
    AmountDueval = [];
    DueDateval = [];
    repaymentIds = [];
    error;
    //@track isFieldsDisabled = false;
    @track isSaveButtonDisabled = false;

    @wire(getrepayment, { recordID: '$recordID' })
    wiredgetrepayment({ error, data }) {

        if (data) {
            console.log('@@@ data', data);
            console.log('@@@ data.length', data.length);
            var val1 = '';
            var val2 = '';
            for (let i = 0; i < data.length; i++) {
                val1 = data[i].Amount_Due__c;
                this.AmountDueval[i] = val1;
                val2 = data[i].Due_Date__c;
                this.DueDateval[i] = val2;
                this.repaymentIds[i] = data[i].Id;
            }

        }

        else if (error) {
            this.error = error;
            console.log('@@@ error in repaymentRecords', this.error);
        }
    }

    connectedCallback() {
        this.initializeIteration();
    }
    initializeIteration() {
        //----------Amount Due calculation---------- 
        console.log('Loan disbursed amount from flow', this.LoanPrincipalDisbursed);
        let principaldisbursed = this.LoanPrincipalDisbursed;
        //let principaldisbursed = this.LoanPrincipalDisbursed.split('.')[0];
        console.log('Loan Disbursed Amount after Conversion ', principaldisbursed);

        var countLoanTerms = parseInt(this.countloanterms);
        console.log('countLoanTerms', countLoanTerms);

        this.newamount = (principaldisbursed / countLoanTerms);
        console.log('@@@ Repayment Schedule Amount Due', this.newamount);

        //----------Due Date calculation---------- 
        console.log('@@@ Loan disbursed Date from flow ', this.LoanDisbursementDate);
        console.log('@@@ Loan Schedule from flow ', this.LoanSchedule);
        if (this.LoanSchedule == 'Monthly') {
            const startingDate = new Date(this.LoanDisbursementDate);
            console.log('@@@ Loan disbursed Date after convert to date', startingDate);
            let numberOfMonths = this.countloanterms;
            console.log('@@@ number of months', numberOfMonths);

            for (let i = 1; i <= numberOfMonths; i++) {
                let storedate = startingDate;
                storedate.setMonth(startingDate.getMonth() + 1);
                console.log('@@@ storedate', storedate);
                this.dates.push(storedate.toISOString().slice(0, 10));
            }
            console.log('@@@ dates are ', this.dates);
        }

        console.log('@@@ Prior count loan terms value', this.Priorcountloanterms);
        //----------push data into items----------
        // 1. When Repayment is creating 
        if (this.Store_CreatedLoanID != undefined) {
            this.iscreateloan = true;
            for (let i = 0; i < this.countloanterms; i++) {
                this.loanterms.push(i + 1);
                this.items.push({
                    Loan_Repayment_Number__c: i + 1,
                    Amount_Due__c: this.newamount,
                    Due_Date__c: this.dates[i]
                });
            }
            console.log('items', this.items);
            console.log('items from if ', typeof (this.items));
        }

        // 2. When Repayment is updating and countloanterms is less than Priorcountloanterms
        else if (this.recordID != undefined) {
            console.log('inside connected call back to update record');
            deleterecords({ loanid: this.recordID })
            console.log('Records are deleted');
            this.isupdateloan = true;
            for (let i = 0; i < this.countloanterms; i++) {
                this.loanterms.push(i + 1);
                this.items.push({
                    Loan_Repayment_Number__c: i + 1,
                    Amount_Due__c: this.newamount,
                    Due_Date__c: this.dates[i]
                });
            }
            console.log('@@@ items When Repayment is updating', this.items);
        }
    }

    handleChange(event) {
        const index = event.target.dataset.index;
        const field = event.target.name;
        const value = event.target.value;
        const recid = event.target.dataset.id;

        // Create a shallow copy of the specific item in the items array
        let updatedItem = { ...this.items[index] };

        // Update the specific field (Amount_Due__c or Due_Date__c) in the copied item
        updatedItem[field] = value;
        updatedItem['Id'] = recid;

        // Create a new items array and update the specific item in it
        let updatedItems = [...this.items];
        updatedItems[index] = updatedItem;

        // Assign the updated items array back to the items property
        this.items = updatedItems;
    }

    handleSave() {
        console.log('items ', JSON.stringify(this.items));
        console.log('create loan ID ', this.Store_CreatedLoanID);
        console.log('Updated Loan ID', this.recordID);

        try {
            console.log('Inside Save Block');

            var recid;
            if (this.Store_CreatedLoanID != undefined) {
                console.log('Inside If Block for creating record ');
                recid = this.Store_CreatedLoanID;
                console.log('rec ID in Create Record ', recid);
                createrecords({ loanid: recid, loanterms: this.loanterms.length, repayments: this.items })
                    .then((result) => {
                        console.log('@@@ result is', JSON.stringify(result));

                        if (result != null && result != undefined) {
                            this.isSaveButtonDisabled = true;

                            // Show a success toast message
                            const toastEvent = new ShowToastEvent({
                                title: 'Success',
                                message: 'Repayments created successfully',
                                variant: 'success'
                            });

                            this.dispatchEvent(toastEvent);
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: {
                                    recordId: recid,
                                    objectApiName: 'Loan__c',
                                    actionName: 'view'
                                }
                            });

                        }

                    })
                    .catch((error) => {
                        console.log('@@@ error is', JSON.stringify(error));

                        // Show an error toast message
                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'An Error occurred while Creating Repayments',
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                    });

            }
            else {
                console.log('Inside else Block for updatting record ');
                recid = this.recordID;
                console.log('rec ID in Update Record ', recid);

                updaterecords({ loanid: recid, loanterms: this.loanterms.length, repayments: this.items })
                    .then((result1) => {
                        console.log('Record is updated');
                        console.log('@@@ result is', JSON.stringify(result1));

                        if (result1 != null && result1 != undefined) {
                            // to disable save button after saving 
                            this.isSaveButtonDisabled = true;

                            // Show a success toast message
                            const toastEvent = new ShowToastEvent({
                                title: 'Success',
                                message: 'Repayments updated successfully',
                                variant: 'success'
                            });
                            this.dispatchEvent(toastEvent);

                            eval("$A.get('e.force:refreshView').fire();");

                            window.setTimeout(() => {
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: recid,
                                        objectApiName: 'Loan__c',
                                        actionName: 'view'
                                    }
                                })

                            }, 2000);
                        }
                    })
                    .catch((error) => {
                        console.log('@@@ error is', JSON.stringify(error));

                        // Show an error toast message
                        const toastEvent = new ShowToastEvent({
                            title: 'Error',
                            message: 'An Error occurred while Updating Repayments' + error,
                            variant: 'error'
                        });
                        this.dispatchEvent(toastEvent);
                    });
            }

        }
        catch (e) {
            console.log("Something went wrong", e);
        }
    }
    /*handleCancel() {
         var items = [];
         console.log('@@@ items', this.items);
         for (var val of this.items) {
             val.Due_Date__c = '';
             items.push(val);
         }
         console.log('### items', items);
         this.items = [];
         this.items = items;
 
     }*/

}