import { LightningElement, track,api } from 'lwc';
import { RefreshEvent } from 'lightning/refresh';
export default class bannerButtons extends LightningElement {
    @track recordId = '00O9D000000vjG9UAI';
    @track isShowModalCancel = false;
    @track isShowModalEdit = false;
    @track isShowModalSubmit = false;
    @api recordId;
    @api inputVariables;    
    connectedCallback()
    {
        console.log('In connected callback');
        console.log(this.loanProposalStatusField);
        const currentPageUrl = window.location.href;
        const parts = currentPageUrl.split('/'); 
        if(parts.indexOf('loan')>=0){
            this.recordId =parts[parts.indexOf('loan') + 1];
            this.inputVariables = [
		{
			name: "recordId",
			type: "String",
			value: this.recordId,
		},
	];
        }
        
    }

    showModalCancel() {
        this.isShowModalCancel = true;
        console.log('@@@ inside modal');

        setTimeout(() => {
            const flowComponent = this.template.querySelector('.flowModal');
            console.log('@@@', flowComponent);
            if (flowComponent) {
                const flowName = 'LWC_CancelledLoanFlow'; 
                console.log('@@@ flowName', flowName);
                flowComponent.startFlow(flowName, this.inputVariables);
            }
        }, 4000)


        //this.template.querySelector('lightning-flow').startFlow('LWC_FSP_CreateLoanProcess', this.inputVariables);
    }
    showModalEdit() {
        this.isShowModalEdit = true;
        console.log('@@@ inside modal');

        setTimeout(() => {
            const flowComponent = this.template.querySelector('.flowModal');
            console.log('@@@', flowComponent);
            if (flowComponent) {
                const flowName = 'LWC_FSP_CreateLoanProcess'; 
                console.log('@@@ flowName', flowName);
                flowComponent.startFlow(flowName, this.inputVariables);
            }
        }, 4000)


        //this.template.querySelector('lightning-flow').startFlow('LWC_FSP_CreateLoanProcess', this.inputVariables);
    }
    showModalSubmit() {
        this.isShowModalSubmit = true;
        console.log('@@@ inside modal');

        setTimeout(() => {
            const flowComponent = this.template.querySelector('.flowModal');
            console.log('@@@', flowComponent);
            if (flowComponent) {
                const flowName = 'LWC_LoanProcessForApproval'; 
                console.log('@@@ flowName', flowName);
                flowComponent.startFlow(flowName, this.inputVariables);
            }
        }, 4000)


        //this.template.querySelector('lightning-flow').startFlow('LWC_FSP_CreateLoanProcess', this.inputVariables);
    }
    hideModalBoxCancel() {
        this.isShowModalCancel = false;
    }
    hideModalBoxEdit() {
        this.isShowModalEdit = false;
    }
    hideModalBoxSubmit() {
        this.isShowModalSubmit = false;
    }

    

    handleStatusChange(event) {
        if (event.detail.status === "FINISHED") {
            console.log(event.detail.status);
			window.location.replace(window.location.href);

		}
    }
}