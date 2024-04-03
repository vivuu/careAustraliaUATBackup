import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class CallFlow extends NavigationMixin(LightningElement) {
    @track recordId = '00O98000000LkCrEAK';
    @track isShowModal = false;

    handleonClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Report',
                actionName: 'view',
            },
        });
        /*this[NavigationMixin.Navigate]({
           type: 'standard__objectPage',
           attributes: {
               objectApiName: 'Report',
               actionName: 'home'
           },
       });*/

    }

    showModalBox() {
        this.isShowModal = true;
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
    hideModalBox() {
        this.isShowModal = false;
    }

    get inputVariables() {
        return [];
    }

    handleStatusChange(event) {
        console.log('handleStatusChange', event.detail);
    }
}