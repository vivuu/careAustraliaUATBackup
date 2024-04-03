import { LightningElement, track, api } from 'lwc';
import updatePaymentMethod from '@salesforce/apex/StripeAddUpdateDDonRD.updatePaymentMethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class CreditCardPayment extends LightningElement {
    @track BSBNumber;
    @track AccountNumber;
    @track PayeeEmail;
    @track PayeeName;
    @api recordId;
    @track isLoading = false;
    @track finanIns;

closeQuickAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
}

handleChangeBSBNumber(event) {
    this.BSBNumber = event.target.value;
}

handleChangeAccountNumber(event) {
    this.AccountNumber = event.target.value;
}

handleChangePayeeEmail(event) {
    this.PayeeEmail = event.target.value;
}

handleChangePayeeName(event) {
    this.PayeeName = event.target.value;
}
handleChangeFI(event){
    this.finanIns = event.target.value;
}
OnSubmit(){
    try{
        this.isLoading = true;
        let elements = this.template.querySelectorAll('lightning-input');
        let stop = true;
        elements.forEach( element=>
            {if((element.value.trim() == '' || element.value == null) && element.label != 'Financial Institution' ){
                stop = false;
            }}
        );
        if(stop){
            updatePaymentMethod({bsb_number : this.BSBNumber, account_number : this.AccountNumber, name : this.PayeeName, email : this.PayeeEmail, rdId : this.recordId, financialIns : this.finanIns})
            .then(result => {
                this.isLoading = false; 
                if( result == 'null' || result == undefined || result == null ){
                    const toastSuccess = new ShowToastEvent({
                        variant: 'success',
                        message: 'Payment method added successfully!'
                    });
                    this.dispatchEvent(toastSuccess);
                    eval("$A.get('e.force:refreshView').fire();");
                    if (result){
                        updateRecord({ fields: { Id: this.recordId }});
                    }
                    this.closeQuickAction();
                }else{
                    //Error handling
                    var msg = result;
                    if( result.includes( '{' ) ){
                        var pRes = JSON.parse( result );
                        msg = pRes.error.message;
                        if( result.includes( 'PaymentMethod' ) && result.includes( 'null' ) ){
                            msg = 'Invalid Bank Details'
                        }
                        console.log(pRes.error.message);
                    }
                    const toastSuccess = new ShowToastEvent({
                        variant: 'error',
                        message: msg
                    });
                    this.dispatchEvent(toastSuccess);
                }
                console.log(result);   
            })
            .catch(error => {
                this.isLoading = false;
                const toast = new ShowToastEvent({
                    variant: 'error',
                    message: 'Error'
                });
                this.dispatchEvent(toast);
                console.log(error);
            });
            }else{
            const toast = new ShowToastEvent({
                variant: 'error',
                message: 'Fill Mandatory Fields'
            });
            this.dispatchEvent(toast);
            this.isLoading = false;
        }
        
    } catch(e){
        console.log(e);
    }   
}
}