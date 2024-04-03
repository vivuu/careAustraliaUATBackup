import { LightningElement,wire } from 'lwc';
import Id from '@salesforce/user/Id';
import executeOffsetCalculationManually from '@salesforce/apex/LWCAdminSettingsCtrl.executeOffsetCalculationManually';
import updateFXRatesManually from '@salesforce/apex/LWCAdminSettingsCtrl.updateFXRatesManually';
import getVisibilityDetails from '@salesforce/apex/ApprovalComponentController.getPermissionSetDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Tab_LWCAdminSettings extends LightningElement {
    spin = false;
    userId = Id;
    isVisible=false;
    handleOffsetCalculation() {
        executeOffsetCalculationManually({}).then(result => {
            console.log('result--> ' + result);
        }).catch(error => {
            console.log('Erroccured:- ' + error.message);
        })
    }

    @wire(getVisibilityDetails, {userId: '$userId'})
    wiredVisibility({ error, data }) {
        console.log(data);
        if (data) {
            for (let i = 0; i < data.length; i++) 
            {
                
                if(data[i]==='LWC_Admin')
                {
                    
                    this.isVisible=true;

                }
            }
        }
        else if(error)
        {
            console.log('error',JSON.stringify(error));
        }
    }


    handleUpdateFXRates() {
        this.spin = true;
        updateFXRatesManually({}).then(result => {
            this.spin = false;
            console.log('result--> ' + result);
            const evt = new ShowToastEvent({
                message: 'Successfully updated the currencies',
                variant: 'Success',
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            console.log('Erroccured:- ' + error.message);
            this.spin = false;
            const evt = new ShowToastEvent({
                message: error,
                variant: 'Error',
            });
            this.dispatchEvent(evt);
        })
    }


}