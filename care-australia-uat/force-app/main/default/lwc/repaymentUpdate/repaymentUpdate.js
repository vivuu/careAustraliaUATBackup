import { LightningElement, track, wire, api } from 'lwc';
import readFile from '@salesforce/apex/FSP_UpdateRepaymentsCtrl.readCSVFile1';
import ACCOUNT_OBJECT from '@salesforce/schema/Repayment_Schedule__c';
import TYPE_FIELD from '@salesforce/schema/Repayment_Schedule__c.Non_performing_loan_options__c';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import saveRepaymentsProcess from '@salesforce/apex/FSP_UpdateRepaymentsCtrl.saveRepayments';

const columns = [

    { label: 'Repayment Schedule: ID', fieldName: 'id', initialWidth: 180, },
    { label: 'Loan: ID', fieldName: 'careLoanID', initialWidth: 111, },
    { label: 'FSP Loan ID', fieldName: 'fspLoanID', initialWidth: 111, },
    { label: 'Location', fieldName: 'location', initialWidth: 100, },
    { label: 'Loan Principal Disbursed', fieldName: 'loanAmount', initialWidth: 190, },
    { label: 'Loan: Currency', fieldName: 'loanCurrency', initialWidth: 111, },
    { label: 'Cumulative Amount Received To Date', fieldName: 'cumulativeAmountReceivedSoFar', initialWidth: 270, },
    { label: 'Total Expected Inc Last Month', fieldName: 'totalExpectedIncLastMonth', initialWidth: 230, },
    { label: 'Last Month Expected Repayment', fieldName: 'lastMonthsExpectedRepayment', initialWidth: 240, },
    {
        label: 'Cumulative Amount Received This Month', type: 'text', fieldName: 'cumulativeAmountReceivedThisMonth', editable: { fieldName: 'isEditable' }, initialWidth: 280,
    },
    {
        label: 'Write Off Request',
        fieldName: 'writeOffRequest',
        type: 'boolean',
        editable: { fieldName: 'isEditable' }, initialWidth: 120,
    }, {
        label: 'Non Performing Options', fieldName: 'nonPerformingOptions', type: 'picklistColumn', editable: { fieldName: 'isEditable' }, initialWidth: 170,
        typeAttributes: {
            placeholder: 'Choose Type',

            options: { fieldName: 'pickListOptions' },
            value: { fieldName: 'nonPerformingOptions' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    { label: 'Comment', fieldName: 'comment', editable: { fieldName: 'isEditable' }, initialWidth: 120, },
    { label: 'Message', fieldName: 'message', initialWidth: 120, },


];

export default class RepaymentUpdate extends LightningElement {

    @track showDatatable = false;
    @track repaymentList = [];
    @track draftValues = [];
    @track pickListOptions = '';
    saveDraftValues = [];
    @track disabled = true;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: TYPE_FIELD
    })

    wirePickList({ error, data }) {
        if (data) {
            this.pickListOptions = data.values;
        } else if (error) {
            console.log(error);
        }
    }
    handleFileClick() {
        let fileInput = this.template.querySelector('input[type="file"]');
        if (fileInput.files.length === 0) {
            this.disabled = true;
        } else {
            this.disabled = false;
        }

    }
    showButton = false;
    handleButtonClick() {
        this.showSpinner = true;
        const fileInput = this.template.querySelector('input[type="file"]');
        if (fileInput.files.length > 0) {
            const file = fileInput.files[0];
            const reader = new FileReader();
            reader.onload = (e) => {
                const csvContent = e.target.result;
                readFile({ csvContent })
                    .then(result => {
                        this.showSpinner = false;
                        if (Array.isArray(result) && result.length === 1 && result[0].errorMessage) {
                            console.log(JSON.stringify(result[0].errorMessage));
                            this.showToast('Error', result[0].errorMessage, 'error', 'dismissable');
                        } else {
                            console.log(JSON.stringify(result));

                            this.repaymentList = result.map(item => ({
                                'id': item.repaymentScheduleID,
                                'careLoanID': item.careLoanID,
                                'fspLoanID': item.fspLoanID,
                                'location': item.location,
                                'loanAmount': item.loanAmount,
                                'loanCurrency': item.loanCurrency,
                                'cumulativeAmountReceivedSoFar': item.cumulativeAmountReceivedSoFar,
                                'totalExpectedIncLastMonth': item.totalExpectedIncLastMonth,
                                'lastMonthsExpectedRepayment': item.lastMonthsExpectedRepayment,
                                'cumulativeAmountReceivedThisMonth': item.cumulativeAmountReceivedThisMonth,
                                'writeOffRequest': item.writeOffRequest,
                                'nonPerformingOptions': item.nonPerformingOptions,
                                'comment': item.comment,
                                'message': item.message,
                                'isEditable': item.isEditable,

                            }));
                            this.repaymentList.forEach(ele => {
                                ele.pickListOptions = this.pickListOptions;
                            })
                            
                            this.editedValues = this.repaymentList.filter(item => item.cumulativeAmountReceivedThisMonth && item.isEditable && (item.message===null||item.message===''));
                            let shouldShowButton = this.repaymentList.some(item => item.cumulativeAmountReceivedThisMonth && item.isEditable && (item.message===null||item.message===''));
                            console.log('editedValues--> ' + JSON.stringify(this.editedValues))
                            this.showButton = shouldShowButton;
                            console.log('this.showButton--> ' + this.showButton)
                            this.showDatatable = true;
                        }


                    })
                    .catch(error => {
                        this.showSpinner = false;
                        this.showToast('Error', 'Error processing CSV file:' + error, 'error', 'dismissable');
                        console.log('Error processing CSV file:', error);
                    });
            };
            reader.readAsText(file);
        }
    }

    @track editedValues = [];
    handleCellChange(event) {
        this.showButton = false;
        let draftValues = event.detail.draftValues;
        draftValues.forEach(updateItem => {
            console.log('values-->' + updateItem.cumulativeAmountReceivedThisMonth)
            if (updateItem.hasOwnProperty("cumulativeAmountReceivedThisMonth")) {
                updateItem.cumulativeAmountReceivedThisMonth = updateItem.cumulativeAmountReceivedThisMonth.replace(/\t/g, "").trim();
            }
            let index = this.repaymentList.findIndex(item => item.id === updateItem.id);
            if (index !== -1) {
                for (let field in updateItem) {
                    if (this.repaymentList[index].hasOwnProperty(field)) {
                        this.repaymentList[index][field] = updateItem[field];
                    }
                }
            }
            let existingEditedItemIndex = this.editedValues.findIndex(item => item.id === updateItem.id);
            if (existingEditedItemIndex === -1) {
                this.editedValues.push(this.repaymentList[index]);
            }
            let shouldRemove = false;
            // condition to determine if a value was cleared for each row
            let editedItem = this.editedValues.find(item => item.id === updateItem.id);
            if (editedItem) {
                if ((editedItem.cumulativeAmountReceivedThisMonth === '' || editedItem.cumulativeAmountReceivedThisMonth === undefined) &&
                    (editedItem.nonPerformingOptions === '' || editedItem.nonPerformingOptions === undefined) &&
                    (editedItem.comment === '' || editedItem.comment === undefined) &&
                    (editedItem.writeOffRequest === undefined || editedItem.writeOffRequest === '' || editedItem.writeOffRequest === false)
                ) {
                    shouldRemove = true;
                }
            }

            if (shouldRemove) {
                let existingEditedItemIndex = this.editedValues.findIndex(item => item.id === updateItem.id);
                if (existingEditedItemIndex !== -1) {
                    // Remove the item from this.editedValues
                    this.editedValues.splice(existingEditedItemIndex, 1);
                }
            }
            console.log('this.editedValues--> ' + JSON.stringify(this.editedValues));
        });
    }
    showSpinner = false;
    handleSave(event) {
        this.showSpinner = true;
        console.log('values-->' + JSON.stringify(this.editedValues));
        saveRepaymentsProcess({ rsList: JSON.stringify(this.editedValues) }).then(result => {
            this.showSpinner = false;
            if (Array.isArray(result) && result.length === 1 && result[0].errorMessage) {
                console.log(JSON.stringify(result[0].errorMessage));
                this.showToast('Error', result[0].errorMessage, 'error', 'dismissable');
            } else {
                console.log(JSON.stringify(result));
                this.editedValues.forEach(updateItem => {
                    let index = this.repaymentList.findIndex(item => item.id === updateItem.id);

                    console.log('index-->' + index)
                    if (index !== -1) {
                        for (let field in updateItem) {
                            if (this.repaymentList[index].hasOwnProperty(field)) {
                                this.repaymentList[index][field] = updateItem[field];
                                this.repaymentList[index].isEditable = false;
                            }
                        }
                    }
                });

                this.editedValues = [];
                this.template.querySelector("c-fsp_-repayment-custom-data-tabel").draftValues = [];
                // Refresh the data table to reflect the changes
                this.refresh();
                this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
                this.showButton = false;
            }

        }).catch(error => {
            console.log('Erroccured:- ' + error.message);
            this.showSpinner = false;
            this.showToast('Error', 'An Error Occurred!', 'error', 'dismissable');
        })
    }
    async refresh() {
        await refreshApex(this.repaymentList);
    }
     
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.showButton = false;
       
        this.editedValues.forEach(item => {
            const indexInRepaymentList = this.repaymentList.findIndex(row => row.id === item.id);

            if (indexInRepaymentList !== -1) {
                this.repaymentList[indexInRepaymentList].comment = '';
                this.repaymentList[indexInRepaymentList].nonPerformingOptions = '';
                this.repaymentList[indexInRepaymentList].writeOffRequest = false;
                this.repaymentList[indexInRepaymentList].cumulativeAmountReceivedThisMonth = '';
            }
        });
        this.editedValues = [];
        
        // this.template.querySelector("c-fsp_-repayment-custom-data-tabel").draftValues = [];
    }
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
    get columns() {
        return columns;
    }
}