import { LightningElement, api, wire } from 'lwc';
import getLoanDetails from '@salesforce/apex/LoanRecordViewCompController.getLoanDetails';

export default class RelatedObjectsComponent extends LightningElement {
    @api recordId; // Parent record ID
    recId;
    loanDetails;
    nameField;
    proposalStatus;
    
 connectedCallback()
    {
        console.log('In connected callback');
        console.log(this.loanProposalStatusField);
        const currentPageUrl = window.location.href;
        const parts = currentPageUrl.split('/'); 
        if(parts.indexOf('loan')>=0){
            this.recordId =parts[parts.indexOf('loan') + 1];
        }
        
    }
    @wire(getLoanDetails, { recordId: '$recordId'})
    wiredLoanDetails({ error, data }) {
        if (data) {
            console.log('data',data);
            this.loanDetails = data;
            this.nameField=this.loanDetails['Name'];
            if(this.loanDetails['Loan_Proposal_Status__c']==='Draft')
                this.proposalStatus=true;
            else if(this.loanDetails['Loan_Proposal_Status__c']==='Rejected')
                this.proposalStatus=true;
            else if(this.loanDetails['Loan_Proposal_Status__c']==='System Rejected')
                this.proposalStatus=true;
            else
                this.proposalStatus=false;
            console.log(this.proposalStatus);
        } else if(error){
        this.errors= error;
        console.log('error',error);
        }
    }


}