import { LightningElement, api, wire } from 'lwc';
import getRelatedRepaymentSchedules from '@salesforce/apex/LoanRecordViewCompController.getRelatedRepaymentSchedules';

export default class RelatedObjectsComponent extends LightningElement {
    @api recordId; // Parent record ID
    recId;
    relatedRepaymentSchedules = [];
    errors;
 connectedCallback()
    {
        console.log('In connected callback');
        const currentPageUrl = window.location.href;
        const parts = currentPageUrl.split('/'); 
        if(parts.indexOf('loan')>=0){
            this.recordId =parts[parts.indexOf('loan') + 1];
        }
        
    }
    @wire(getRelatedRepaymentSchedules, { recordId: '$recordId'})
    wiredRepaymentSchedules({ error, data }) {
        if (data) {
            console.log('data',data);
            this.relatedRepaymentSchedules = data;

        } else if(error){
        this.errors= error;
        console.log('error',error);
        }
    }


}