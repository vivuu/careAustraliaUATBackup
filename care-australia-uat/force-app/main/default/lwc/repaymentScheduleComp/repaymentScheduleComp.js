import { LightningElement, api } from 'lwc';

import NAME_FIELD from '@salesforce/schema/Repayment_Schedule__c.Name';
import CARELOANID_FIELD from '@salesforce/schema/Repayment_Schedule__c.Loan__c';
import LOANREPAYMENTNUMBER_FIELD from '@salesforce/schema/Repayment_Schedule__c.Loan_Repayment_Number__c';
import AMOUNTDUE_FIELD from '@salesforce/schema/Repayment_Schedule__c.Amount_Due__c';
import DUEDATE_FIELD from '@salesforce/schema/Repayment_Schedule__c.Due_Date__c';
import STATUS_FIELD from '@salesforce/schema/Repayment_Schedule__c.Status__c';
import CREATEDBY_FIELD from '@salesforce/schema/Repayment_Schedule__c.CreatedById';
import PRINCIPALREPAID_FIELD from '@salesforce/schema/Repayment_Schedule__c.Principal_Repaid__c';
import REPAYMENTDATE_FIELD from '@salesforce/schema/Repayment_Schedule__c.Repayment_Date__c';
import NONPERFORMINGLOANOPTIONS_FIELD from '@salesforce/schema/Repayment_Schedule__c.Non_performing_loan_options__c';
import NONPERFORMINGLOANOPTIONSOTHER_FIELD from '@salesforce/schema/Repayment_Schedule__c.Non_performing_loan_options_other__c';
import LASTMODIFIED_FIELD from '@salesforce/schema/Repayment_Schedule__c.LastModifiedById';


export default class RepaymentScheduleComp extends LightningElement {
    nameField = NAME_FIELD;
    careLoanIdField = CARELOANID_FIELD;
    loanRepaymentNumberField = LOANREPAYMENTNUMBER_FIELD;
    amountDueField = AMOUNTDUE_FIELD;
    dueDateField = DUEDATE_FIELD;
    statusField = STATUS_FIELD;
    createdByField = CREATEDBY_FIELD;
    principalRepaidField = PRINCIPALREPAID_FIELD;
    repaymentDateField = REPAYMENTDATE_FIELD;
    nonPerformingLoanOptionsField = NONPERFORMINGLOANOPTIONS_FIELD;
    nonPerformingLoanOptionsOtherField = NONPERFORMINGLOANOPTIONSOTHER_FIELD;
    lastModifiedField = LASTMODIFIED_FIELD;

    @api recordId;
    @api objectApiName;
}