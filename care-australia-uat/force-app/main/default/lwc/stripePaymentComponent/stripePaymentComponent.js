import { LightningElement, api } from 'lwc';

import { LoadEvent, ContinueEvent, PayEvent } from './events';

import AmericanExpress from '@salesforce/resourceUrl/AmericanExpress';
import CCard from '@salesforce/resourceUrl/CCard';
import VisaCard from '@salesforce/resourceUrl/VisaCard';
import StripeImage from '@salesforce/resourceUrl/StripeImage';

export default class StripePaymentComponent extends LightningElement {
    /**
     * values possible - CreditCard, GooglePay
     * Add other payment values as per the development
     */
    @api paymentType;

    @api contactid;

    @api amount;

    @api vfPageDomain;

    @api createTokenForRd;

    @api constantContactId;

    connectedCallback() {
        window.addEventListener('message', this.handleMessage.bind(this));
    }

    disconnectedCallback() {
        window.removeEventListener('message', this.handleMessage);
    }
    
    handleMessage(event) {
        // Check the origin of the message for security
        if (event.origin !== this.vfPageDomain) {
            return;
        }

        // Parse the message data
        const data = JSON.parse(JSON.stringify(event.data));

        // Handle the message data as needed
        console.log('Received message from VF page:', data);

        const dataKeys = Object.keys(data);

        // You can now process the response data from the VF page
        if(dataKeys.includes('isLoading')) {
            this.dispatchEvent(new LoadEvent(data.isLoading));
        } else if(dataKeys.includes('token')) {
            let rdToken = null;
            if(dataKeys.includes('rdToken')) {
                rdToken = data.rdToken;
            }
            this.dispatchEvent(new ContinueEvent(data.token, rdToken));
        } else if(dataKeys.includes('paymentMethod')) {
            this.dispatchEvent(new PayEvent(data.paymentMethod));
        }
    }

    get creditPaymentType() {
        return this.paymentType === 'CreditCard';
    }

    get googlePaymentType() {
        return this.paymentType === 'GooglePay';
    }

    get iframeURL() {
        let subDomain;
        if(this.vfPageDomain.includes('sandbox.vf.force')) {
            subDomain = 'apex';
        } else {
            subDomain = 'payments';
        }
        const domain = this.vfPageDomain + '/' + subDomain + '/';

        let conId = this.contactid ? this.contactid : this.constantContactId;

        if(this.creditPaymentType) {
            console.log(domain + 'stripeCreditCardPaymentPage?id=' + conId + '&createTokenForRd=' + this.createTokenForRd);
            return domain + 'stripeCreditCardPaymentPage?id=' + conId + '&createTokenForRd=' + this.createTokenForRd;
        } else if(this.googlePaymentType) {
            console.log(domain + 'stripeGooglePayPaymentPage?id=' + conId + '&amount=' + (this.amount*100));
            return domain + 'stripeGooglePayPaymentPage?id=' + conId + '&amount=' + (this.amount*100);
        }
        return '';
    }

    get AmericanExpress() {
        return AmericanExpress;
    }

    get CCard() {
        return CCard;
    }   
    
    get VisaCard() { 
        return VisaCard;
    }

    get StripeImage() {
        return StripeImage;
    }
}