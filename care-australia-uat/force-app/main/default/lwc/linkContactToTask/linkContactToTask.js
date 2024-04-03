import { LightningElement, wire, track, api  } from 'lwc';
import getContactsForTask from '@salesforce/apex/LinkContactCtrl.getContactsForTask';
import updatetask from '@salesforce/apex/LinkContactCtrl.updatetask';
export default class LinkContactToTask extends LightningElement {
@api recordId;
error;
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
    //{ label: 'Contact Phone ', fieldName: 'Phone', type:'Number' },
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

@wire(getContactsForTask, {recordId: '$recordId'})
wiredcontact ({error,data}){

    if(error){
        this.error = 'Records not found';
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

handleupdatetask(event){
    try{
        console.log("###Recordid", this.recordId);

        var selectedcontactid = JSON.stringify(event.detail.row.Id);
        console.log("###Selected Contact Id", selectedcontactid);

        updatetask({taskId:this.recordId, contactId:JSON.parse(selectedcontactid)})
        .then((result) => {
            console.log('test');
            console.log('###Updated Task Detail'+JSON.stringify(result));
            //window.location.reload();
            eval("$A.get('e.force:refreshView').fire()");
        })
        .catch((error)=>{
            this.errorMessage = error;
            console.log('###error show',JSON.stringify(this.errorMessage));
        })
    }
    catch(e){
        console.log('not update'+e);   
    }

}

}