import { LightningElement, wire, api } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/NotesAndAttachmentsController.getRelatedFilesByRecordId';
import {NavigationMixin} from 'lightning/navigation';

export default class NotesAndAttachmentsComp extends NavigationMixin(LightningElement) {
    
    @api recordId;
    allAttachments =[]
    connectedCallback()
    {
        console.log('In connected callback');
        const currentPageUrl = window.location.href;
        const parts = currentPageUrl.split('/'); 
        if(parts.indexOf('loan')>=0){
            this.recordId =parts[parts.indexOf('loan') + 1];
        }
        
    }
    @wire(getRelatedFilesByRecordId, {recordId : '$recordId'})
    wiredAttachments({data, error}){ 
        if(data){ 
            console.log('Data'+JSON.stringify(data));
            this.allAttachments = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
              "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log('Hi-->'+this.filesList);
            
            
        }
        if(error){ 
            console.log(error);
        }
    }
    previewHandler(event){
        console.log('@@@ target ID',event.target.dataset.id);
        var storeTargetid = event.target.dataset.id;
        console.log('@@@ target ID into variable',storeTargetid);
        this[NavigationMixin.Navigate]({ 
            type : 'standard__namedPage',
            attributes:{ 
                pageName :'filePreview',
               // actionName : 'view'
            },
            state:{ 
                selectedRecordId: event.target.dataset.id
            }
        })
    }   
}