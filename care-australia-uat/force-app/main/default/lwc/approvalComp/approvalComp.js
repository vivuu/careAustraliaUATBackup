import { LightningElement,api,  wire ,track} from 'lwc';
import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import LOAN_PROPOSAL_FIELD from '@salesforce/schema/Loan__c.Loan_Proposal_Status__c';
import STAGE_FIELD from '@salesforce/schema/Loan__c.Stage__c';
import getVisibilityDetails from '@salesforce/apex/ApprovalComponentController.getPermissionSetDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ApprovalComp extends LightningElement 
{
    @api recordId;
    @api inputVariables;
    @track isShowWriteOff = false;
    @track isShowRepayment = false;

    userId = Id;
    isVisibile_LWCLoan_desc=false;
    isVisible_LWC_feature=false;
    isVisible_CA_Themes=false;
    isVisible_CA_disbursed=false;
    isVisible_Published=false;
    isVisibleContentFields=false;
    isVisible_Stage=false;
    isVisible=false;
    isWriteOffbutton=false;
    isRepaymentButton=false;
    status;
    stage;

    connectedCallback() {
        
        this.inputVariables = [
		{
			name: "recordId",
			type: "String",
			value: this.recordId,
		},
	];
    }
     @wire(getRecord, {recordId: '$recordId', fields: [LOAN_PROPOSAL_FIELD,STAGE_FIELD]})
     loanRec({error, data}){
        if(data){
            this.status=getFieldValue(data, LOAN_PROPOSAL_FIELD);
            this.stage=getFieldValue(data, STAGE_FIELD);
            
        }else if(error){
           console.log('error',JSON.stringify(error));
        }
    }

    @wire(getVisibilityDetails, {userId: '$userId'})
    wiredVisibility({ error, data }) {
        console.log(data);
        if (data) {
            console.log(data+"     "+this.status);
            for (let i = 0; i < data.length; i++) {
                if(data[i]==='LWC_Loan_Reviewers')
                {
                    this.isVisible=true;
                     
                    if((this.status === 'Under Review')||(this.status === 'Content Approved')||(this.status === 'Published')||(this.status === 'Active'))
                    {
                        this.isVisible_LWC_feature=true;
                    }
                    if(this.status === 'Under Review')
                    {
                        
                        this.isVisibleContentFields=true;
                    } 
                    if(this.status != 'Published')
                    {
                        this.isVisible_Published=true;
                    }
                    console.log('In reviewer');
                }
                if(data[i]==='LWC_Loan_Managers')
                {
                    this.isVisible=true;
                    if(this.status === 'Content Approved')
                    {
                        this.isVisibleContentFields=true;
                    }
                    if((this.status === 'Published')||(this.status === 'Content Approved')||(this.status === 'Active'))
                    {
                        this.isVisible_LWC_feature=true;
                    }
                    if(this.status != 'Published')
                    {
                        this.isVisible_Published=true;
                    }
                    console.log('In manager');
                }
                if(data[i]==='LWC_Content_Managers')
                {
                    
                    this.isVisible=true;
                    if(this.stage != 'Published')
                    {
                        this.isVisible_Published=true;
                    }
                    if(this.status === 'Published')
                    {
                        this.isVisible_LWC_feature=true;
                    }
                    if(this.status === 'Content Approved')
                    {
                        this.isVisibleContentFields=true;
                        
                    }
                    
                    console.log('In content manager');
                }
                if(data[i]==='LWC_Admin')
                {
                    this.isVisibleContentFields=true;
                    this.isVisible=true;
                    this.isRepaymentButton=true;
                    console.log('Repayment button-->'+this.isRepaymentButton);
                    this.isVisible_CA_Themes=true;
                    this.isVisible_CA_disbursed=true;
                    if(this.status === 'Published')
                    {
                        this.isVisible_LWC_feature=true;
                    }
                    if(this.stage != 'Published')
                    {
                        this.isVisible_Published=true;
                    }
                    if(this.stage === 'Active')
                        this.isWriteOffbutton=true;
                    console.log('In LWC Admin');

                }
              
                if(data[i]==='LWC_Programs_Manager')
                {
                    this.isVisible_CA_Themes=true;
                    this.isVisible=true;
                    if(this.stage === 'Active')
                        this.isWriteOffbutton=true;
                    if(this.stage != 'Published')
                    {
                        this.isVisible_Published=true;
                    }
                    console.log('Programs Manager');

                }
               
                if(data[i]==='LWC_Finance_Manager')
                {
                    if(this.stage === 'Active')
                    {
                        this.isVisible_CA_disbursed=true;
                        this.isVisible=true;
                    }
                    consoe.log('Finance Manager');
                }

}
    }
    else if(error){
        console.log('error',JSON.stringify(error));
    }
    }

     showWriteOff() {
        this.isShowWriteOff = true;
        console.log('@@@ inside modal');

        setTimeout(() => {
            const flowComponent = this.template.querySelector('.flowModal');
            console.log('@@@', flowComponent);
            if (flowComponent) {
                const flowName = 'LWC_WriteOffLoans'; 
                console.log('@@@ flowName', flowName);
                flowComponent.startFlow(flowName, this.inputVariables);
            }
        }, 4000)


        //this.template.querySelector('lightning-flow').startFlow('LWC_FSP_CreateLoanProcess', this.inputVariables);
    }

     showRepayment() {
        this.isShowRepayment = true;
        console.log('@@@ inside modal');

        setTimeout(() => {
            const flowComponent = this.template.querySelector('.flowModal');
            console.log('@@@', flowComponent);
            if (flowComponent) {
                const flowName = 'LWC_RepaymentScheduleChange'; 
                console.log('@@@ flowName', flowName);
                flowComponent.startFlow(flowName, this.inputVariables);
            }
        }, 4000)


        //this.template.querySelector('lightning-flow').startFlow('LWC_FSP_CreateLoanProcess', this.inputVariables);
    }

    handleSuccess(event)
    {
        const evt = new ShowToastEvent({
      title: 'Test',
      message: 'Record updated!!',
      variant: 'success',
    });
    this.dispatchEvent(evt);
    window.location.replace(window.location.href);
    }

    hideWriteOff() {
        this.isShowWriteOff = false;
    }

     hideRepayment() {
        this.isShowRepayment = false;
    }

     handleStatusChange(event) {
        if (event.detail.status === "FINISHED") {
            console.log(event.detail.status);
			window.location.replace(window.location.href);

		}
    }
}