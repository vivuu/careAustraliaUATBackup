import { LightningElement, api, wire,track } from 'lwc';
import updateChatTranscript from '@salesforce/apex/TaskUpdateChatTranscript.updateChatTranscript';
import updateCall from '@salesforce/apex/TaskUpdateChatTranscript.updateCall';
import getTask from '@salesforce/apex/TaskUpdateChatTranscript.getTask';
import sendEmail from '@salesforce/apex/TaskUpdateChatTranscript.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UpdateChatTranscript extends LightningElement {
    @api recordId;
    @track toValue;
    @track bodyValue;
    //@track subjectValue;
    newSubject;
    record;
    ishandleShowClicked =false;
   @wire(getTask,{ recordId:'$recordId'})
    wiredRecord({data,error}) {
        console.log('### Data:'+JSON.stringify(data));
        if (data) {
            this.record = data[0];
        } 
        else if (error) {
           console.log('### Error Message: '+JSON.stringify(error));
        }
    }
   get subjectValue() {
        return this.record?.Subject;
    }
    /*get bodyValue() {
        return this.record?.Description;
    }*/
    get typeValue() {
        return this.record?.Type;
    }
    get showChatContent() {
        return this.typeValue === 'Chat';
    }
    get showCallContent() {
         return this.typeValue === 'Call';
    }
    handleShow(event){
        this.ishandleShowClicked= true;
    }
    handleCancel(event){
        this.ishandleShowClicked=false;
    }

    handleUpdateChat(event){
        try{
            console.log('### Enter 1');
            console.log('### Recordid: ', this.recordId);
        
            updateChatTranscript({tskId:this.recordId})
            .then((result) => {
                console.log('test');
                console.log('### Updated Task Chat Detail: '+JSON.stringify(result));
                //window.location.reload();
                eval("$A.get('e.force:refreshView').fire()");
            })
            .catch((error)=>{
                this.errorMessage = error;
                console.log('### Error Show: ',JSON.stringify(this.errorMessage));
            }) 
        }
        catch(e){
            console.log('### Not Update: '+e);   
        }   
    }

    handleUpdateCall(event){
        try{
            console.log('### Enter 2');
            var selectedbutton = event.target.label;
            console.log('### Button label:',selectedbutton);

            updateCall({tskId:this.recordId, callType:selectedbutton})
            .then((result) => {
                console.log('test');
                console.log('### Updated Task call Detail: '+JSON.stringify(result));
                //window.location.reload();
                eval("$A.get('e.force:refreshView').fire()");
            })
            .catch((error)=>{
                this.errorMessage = error;
                console.log('### Error Show: ',JSON.stringify(this.errorMessage));
            })
        }
        catch(e){
            console.log('### Not Update: '+e);   
        } 
    }
    handleToChange(event){
        this.toValue=event.target.value;
        console.log("## toValue"+this.toValue);
        
    }
     handleSubjectChange(event){
       this.newSubject =event.target.value;
        console.log("## subjectValue"+this.newSubject);    
    }
     handleBodyChange(event){
        this.bodyValue=event.target.value;
        console.log("## bodyValue"+this.bodyValue);    
    }

    handleSubmit(event) {
        const emailParams = {
            toAddress: this.toValue,
            subject: this.newSubject,
            body: this.bodyValue,
            tskId: this.recordId
        };
        console.log('### Emailparams: '+JSON.stringify(emailParams));
        this.toValue =null;
        this.bodyValue =null;
        console.log('### clear tovalue: '+this.toValue);
        console.log('### clear bodyvalue: '+this.bodyValue);

        sendEmail(emailParams)
            .then(result => {
                eval("$A.get('e.force:refreshView').fire()");
                console.log('### Result: '+result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Email sent successfully.',
                        variant: 'success'
                    })
                );
               
               this.ishandleShowClicked=false;
            })
            .catch(error => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'An error occurred while sending the email.',
                        variant: 'error'
                    })
                );
            });
    }

}