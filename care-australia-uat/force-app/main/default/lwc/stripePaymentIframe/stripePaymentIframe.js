import { api, LightningElement } from 'lwc';
import getPaymentStatus from '@salesforce/apex/StripePaymentByCC.getPaymentStatus';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import StripeVfUrl from '@salesforce/label/c.StripeVfUrl';

export default class StripeIFrame extends LightningElement {
    @api recordId;
    @api height = '500px';
    @api referrerPolicy = 'no-referrer';
    @api sandbox = '';
    @api url = '/apex/StripePaymentPage';
    @api width = '100%';
    flag = 1;
    part;
    urlSource = StripeVfUrl;

    connectedCallback() {
        let vfOrigin = this.urlSource;
        window.addEventListener("message", (message) => { 
            if (message.origin !== vfOrigin) {
                console.log("🚀 ~ message.origin", message.origin);
                return;
            }

            if (message.data.name === "StripePaymentPage") {
                console.log("🚀 ~ message.data.name", message.data.name);
                //Do action
                this.dispatchEvent(new CloseActionScreenEvent());

                
            }
        });
}
    
    renderedCallback(){
        if(this.flag == 2){

        this.part = this.recordId.slice(0,3);
        console.log('part'+this.part);
        if(this.recordId != null && this.part == 'a01'){
            getPaymentStatus({paymentId : this.recordId})
            .then(results => {
                if(results == true){
                    console.log('result'+results);
                    const toastSuccess = new ShowToastEvent({
                        variant: 'success',
                        message: 'Already Paid'
                    });
                    this.dispatchEvent(toastSuccess);
                    this.closeQuickAction();
                }
            })
            .catch( errors => {
                console.log('Contact System admin you have encountered an error');
            });
        }

            this.url += "?id="+this.recordId;
            console.log(this.url);
        }
        this.flag += 1;
        window.addEventListener('CloseAction', this.closeQuickAction);
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
}