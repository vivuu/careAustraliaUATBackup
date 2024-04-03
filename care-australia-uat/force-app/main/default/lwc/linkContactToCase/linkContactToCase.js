import { LightningElement, wire, track, api  } from 'lwc';
import  getContactsForCase from '@salesforce/apex/LinkContactCtrl.getContactsForCase';
import { updateRecord } from "lightning/uiRecordApi";
import ContactId_FIELD from '@salesforce/schema/Case.ContactId';
import CaseId_FIELD from '@salesforce/schema/Case.Id';
//import { refreshApex } from '@salesforce/apex';
export default class linkContactToCase extends LightningElement {
@api recordId;
@api errorMessage;
@track data=[];
@track columns = [
    //{ label: 'Contact Id', fieldName: 'Id', type: 'text'},
    { label: 'Salutation', fieldName: 'Salutation', type: 'text'},  
    { label: 'Contact Name', fieldName: 'ContactNamelink', type: 'url',
        typeAttributes: {
            label: { fieldName: 'ContactName' },
            value: { fieldName: 'ContactNamelink'}, 
            target: '_blank'
            }
    },
    { label: 'Contact Email ', fieldName: 'Email', type: 'Email' },
    {
        type:"button",
        fixedWidth: 100,
        typeAttributes: {
            label: 'Link',
            name: 'Link',
            variant: 'brand', 
        }
    }, 
]; 

@wire( getContactsForCase, {recordId: '$recordId'})
wiredcontact ({error,data}){

    if(error){
        this.error = error;
        this.data = undefined;
    }
    else if(data){
            data = JSON.parse(JSON.stringify(data));
            data.forEach(res => {
                res.ContactNamelink = '/' + res.Id;
                res.ContactName = res.Name;
            });

        this.data = data;
        this.error = undefined;   
        console.log('###',data.length);
        console.log('###',JSON.stringify(data));   
    }       
}

handleupdatecase(event){
    try{
        console.log("###Recordid", this.recordId);
        
        var selectedcontactid = JSON.stringify(event.detail.row.Id);
        console.log("###Selected Contact Id", selectedcontactid);

        /*var selectedcontactname = JSON.stringify(event.detail.row.Name);
        console.log("###Selected Contact Name", selectedcontactname);*/
        
        console.log("###Selected ContactApi name: ", ContactId_FIELD.fieldApiName); // using Schema, case object field 
        console.log("###Selected CaseId_FIELD Api name: ", CaseId_FIELD.fieldApiName);// using Schema, case object field 

        const fields = {};
            fields [CaseId_FIELD.fieldApiName] = this.recordId;
            fields [ContactId_FIELD.fieldApiName] =JSON.parse(selectedcontactid); 
        const recordInput = { fields };
        console.log('record input',recordInput );

        updateRecord(recordInput)
        .then(() => {
            console.log('test');
            //return refreshApex(this.Case);
            eval("$A.get('e.force:refreshView').fire()");
        })
        .catch((error)=>{
            this.errorMessage = error;
            console.log('error show',JSON.stringify(this.errorMessage));
        })

    }
    catch(e){
        console.log('not update'+e);   
    }
    
}
}