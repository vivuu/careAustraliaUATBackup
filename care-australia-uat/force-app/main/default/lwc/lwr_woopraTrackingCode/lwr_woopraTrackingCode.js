import { LightningElement, wire, track } from 'lwc';

import { getRecord, getFieldValue } from "lightning/uiRecordApi";

import isguest from '@salesforce/user/isGuest'; 

import USER_ID from "@salesforce/user/Id";
import EMAIL_FIELD from "@salesforce/schema/User.Email";
export default class Lwr_woopraTrackingCode extends LightningElement {

    @track userId = USER_ID;
    @track isGuestUser = isguest;


    @wire(getRecord, { recordId: '$userId', fields: [EMAIL_FIELD] })
    wiredUser({ error, data }) {
        if (error) {
            console.log(error);
        } else if (data) {
            var emailId = data.fields.Email.value;
            if(!this.isGuestUser){
                console.log('inWoopraCode');
                localStorage.setItem('useremail',emailId);
                localStorage.setItem('userid',this.userId);
                this.dispatchEvent(
                    new CustomEvent(
                                'woopraIdentifyEmail', 
                                { 
                                    detail:{
                                        useremail : emailId
                                    },
                                    bubbles: true, 
                                    composed: true 
                                }
                                )
                );
            }           
        }
    }
}