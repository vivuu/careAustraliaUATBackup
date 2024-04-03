import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Lwr_flowNavigationLWC extends NavigationMixin(LightningElement){

    @api startURL;

    connectedCallback(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.startURL
            }
        },
        true);
    }
}