import { LightningElement,api,wire,track } from 'lwc';
import addCustomer from '@salesforce/apex/StripeBatchGiftEntryCtrl.addCustomer';
import createPaymentRecords from '@salesforce/apex/StripeBatchGiftEntryCtrl.createPaymentRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import StripeVfUrl from '@salesforce/label/c.StripeVfUrl';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';

export default class StripeBatchGiftEntry extends LightningElement {
    @api isAddCustomerPopup=false; //To set the Add Customer Popup visibility
    @api isCreditCardPopup=false;  //To set the Credit Card Payment Popup visibility    
    defaultCustomerValues={donationDate:null,amount:0.00,campaignId:"",campaignName:""}
    newCustomerValues={firstName:"",lastName:"",phone:"",email:"",MailingStreet:"",MailingCity:"",MailingState:"",MailingCountry:"",MailingPostalCode:""}
    giftrowField={
        serialNo:0,
        paymentMethod:"",
        checkRef:"",
        contactId:undefined,
        contactName:'',
        donationDate:"",
        amount:0,
        campaignId:"",
        campaignName:"",
        recurringId:"",
        recurringName:"",
        contactIdentifier:'rowContact-0',
        recurringIdentifier:'rowRecurring-0',
        campaignIdentifier:'rowCampaign-0',
        defaultClass:'slds-hint-parent',
        contactRd:"",
    }
    urlSource = StripeVfUrl;
    isSpinnerActive=false;
    donationTypeValue='Single';
    preferredEmailOptions;
    countOfGifts=0;
    expectedTotalAmount=0;
    @track giftrow=[];
    selectedIndex;
    creditCardNumber;
    expiryMonth;
    expiryYear;
    sumOfAmount=0;

    @api recordId;
    rId;
    @api height = '300px';
    @api referrerPolicy = 'no-referrer';
    @api sandbox = '';
    @api url = '/apex/StripePaymentPage';
    @api width = '100%';
    flag = 1;
    part;
    @api channelName = '/event/Stripe_Credit_Card_Authorize__e';
    connectedCallback(){
        this.handleSubscribe();
        let vfOrigin = this.urlSource;
        window.addEventListener("message", (message) => { 
            console.log('Message', message);
            if( message.data.name == 'Spinner' ){
                this.isSpinnerActive = true;
            }
            else if (message.data.name === "StripePaymentPage") {
                this.isSpinnerActive = false;
                console.log("🚀 ~ message.data.name", message.data.name);
                console.log("🚀 ~ message.data.response", message.data.response);
                var resp = message.data.response;
                if( resp!= undefined ){
                    var res = JSON.parse( resp );
                    console.log(res.error);
                    //Do action
                    var msg = '';
                    var variant = '';
                    if( res.error != undefined ){
                        msg = res.error.message;
                        msg+=' Please Retry'
                        variant = 'error';
                    }else{
                        variant = 'success';
                        msg = 'Card has been successfully authorized!!'
                        var last4 = '************'+res.paymentMethod.card.last4;
                        console.log('l4:',last4);
                        let rowTemp=Object.assign({},this.giftrow.at(this.selectedIndex));//[fieldName]=eventValue;
                        console.log(rowTemp);
                        rowTemp['authCard']=last4;
                        rowTemp['payMethodId']=res.paymentMethod.id;

                        //rowTemp.cardNumber=this.creditCardNumber;
                        rowTemp.expiryMonth=res.paymentMethod.card.exp_month;
                        rowTemp.expiryYear=res.paymentMethod.card.exp_year;
                        // rowTemp.idx=cardPaymentResult.id;
                        // rowTemp.status=cardPaymentResult.status;
                        // rowTemp.name=cardPaymentResult.card.name;
                        rowTemp.last4=res.paymentMethod.card.last4;
                        // rowTemp.cardId=cardPaymentResult.card.id;
                        rowTemp.brand=res.paymentMethod.card.brand;
                        // rowTemp.fingerprint=fingerPrint;
                        
                        this.giftrow[this.selectedIndex]=rowTemp;

                    }            
                    const toastSuccess = new ShowToastEvent({
                        variant: variant,
                        message: msg
                    });
                    this.isCreditCardPopup = false;
                    this.dispatchEvent(toastSuccess);   
                } 
            }
        });
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            try{
                console.log('New message received 1: ', JSON.stringify(response));
                console.log('New message received 2: ', response);
                var obj = JSON.parse(JSON.stringify(response));
                console.log(obj.data.payload);
                console.log(self.channelName);
                let objData = obj.data.payload;
                var name = objData.Name__c;
                var payload = objData.Payload__c;
                var recId = objData.Record_Id__c;
                var res1 = objData.Response__c;
                if( payload == 'spinner' && recId == self.rId ){
                    console.log('Spinner');
                    self.isSpinnerActive = true;
                } else if( payload == 'showToast' && recId == self.rId && name == 'giftEntry' ){
                    console.log('Parsing body');
                    self.isSpinnerActive = false;
                    if( res1!= undefined ){
                        var res = JSON.parse( res1 );
                        console.log(res.error);
                        //Do action
                        var msg = '';
                        var variant = '';
                        if( res.error != undefined ){
                            msg = res.error.message;
                            msg+=' Please Retry'
                            variant = 'error';
                        }else{
                            variant = 'success';
                            msg = 'Card has been successfully authorized!!'
                            var last4 = '************'+res.paymentMethod.card.last4;
                            console.log('l4:',last4);
                            let rowTemp=Object.assign({},self.giftrow.at(self.selectedIndex));//[fieldName]=eventValue;
                            console.log(rowTemp);
                            rowTemp['authCard']=last4;
                            rowTemp['payMethodId']=res.paymentMethod.id;

                            //rowTemp.cardNumber=this.creditCardNumber;
                            rowTemp.expiryMonth=res.paymentMethod.card.exp_month;
                            rowTemp.expiryYear=res.paymentMethod.card.exp_year;
                            // rowTemp.idx=cardPaymentResult.id;
                            // rowTemp.status=cardPaymentResult.status;
                            // rowTemp.name=cardPaymentResult.card.name;
                            rowTemp.last4=res.paymentMethod.card.last4;
                            // rowTemp.cardId=cardPaymentResult.card.id;
                            rowTemp.brand=res.paymentMethod.card.brand;
                            // rowTemp.fingerprint=fingerPrint;
                            
                            self.giftrow[self.selectedIndex]=rowTemp;

                        }            
                        const toastSuccess = new ShowToastEvent({
                            variant: variant,
                            message: msg
                        });
                        self.isCreditCardPopup = false;
                        self.dispatchEvent(toastSuccess);  
                    }
                }
                console.log('-->',name, payload, recId, res, self.rId);
            }catch( err ){
                console.log(err);
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
        });
    }

    handleChange(event){
        let eventVal=event.detail.value;
        let fieldName=event.currentTarget.name;
        if(fieldName==='creditCardNumber'){
            this.creditCardNumber= eventVal; 
        }

        if(fieldName==='expiryMonth'){
            this.expiryMonth= eventVal; 
        }

        if(fieldName==='expiryYear'){
            this.expiryYear= eventVal; 
        }

        if(fieldName==='expectedTotalAmount'){
            this.expectedTotalAmount= eventVal; 
        }

        if(fieldName==='expectedCountOfGifts'){
            this.countOfGifts= eventVal; 
            if(this.countOfGifts>20){
                this.countOfGifts=20; 
            }            
        }

        if(fieldName==='donationType'){
            this.donationTypeValue= eventVal; 
        }       
    }

    // Donation Type picklist option
    get donationTypeOptions() {
        return [
            { label: 'Single', value: 'Single' },
            { label: 'Recurring', value: 'Recurring' },
        ];
    }    

    // Handle Default Customer Field Value Change
    handledefCustFieldChange(event){
        let detail=event.detail;
        let fieldName=event.target.name;
        let type=event.target.type;
        this.defaultCustomerValues[fieldName]=detail.value;       
        //console.log('---'+JSON.stringify(this.defaultCustomerValues));
    } 

    handleNewCustFieldChange(event){
        let detail=event.detail;
        let fieldName=event.target.name;
        let type=event.target.type;
        this.newCustomerValues[fieldName]=detail.value;       
        //console.log('---'+JSON.stringify(this.defaultCustomerValues));
    } 
    

    // To Close All Popup
    handlePopUpCancel(event){
        this.isAddCustomerPopup=false;
        this.isCreditCardPopup=false;
        this.selectedIndex=undefined;
    }

    //Open Add Customer Popup
    OpenAddCustomerModal(event){        
        this.isAddCustomerPopup=true;
    }

    //Open Credit Card Payment Popup
    OpenCreditCardModal(event){
        let index=event.currentTarget.dataset.index;
        console.log(index);
        this.isCreditCardPopup=true;
        let tempGift=Object.assign({},this.giftrow.at(index));
        console.log('Rec:',tempGift);
        console.log(tempGift.recurringId);
        var recId = tempGift.recurringId != undefined && tempGift.recurringId != '' ? tempGift.recurringId :  tempGift.contactId;
        console.log('recId',recId);
        this.rId = recId;
        this.url = '/apex/StripePaymentPage?id='+recId+"&evtName=giftEntry";
        //this.url = '/apex/StripePaymentPage?id='+tempGift.contactId;
        this.selectedIndex=index;
    }

    // Add Customer By Calling Apex
    handleAddCustomer() {
        this.isSpinnerActive=true;
        addCustomer({ contactJsonString: JSON.stringify(this.newCustomerValues) })
            .then((result) => {
                this.handlePopUpCancel();
                this.isSpinnerActive=false;
                this.showToast('Success','Customer added Successfully');
            })
            .catch((error) => {
                this.showToast('!Error','Please contact your administrator : '+error.body.message,'error','sticky');
                console.log('----error'+ JSON.stringify(error));
                this.isSpinnerActive=false;
            });
    }


    // show the success message
    showToast(title, message, variant = 'success', mode = 'dismissible') {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            message: message,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    // Custom Lookup Event Handler
    handleLookupEvent(event){
        //console.log(JSON.stringify(event.detail));
        let lookupDetail=event.detail;
        let recordName=lookupDetail.selectedRecord!==undefined?lookupDetail.selectedRecord.Name:"";
        let recordId=lookupDetail.selectedRecord!==undefined?lookupDetail.selectedRecord.Id:"";
        // Handle For Campaign On Default Customer Values Section
        if(lookupDetail.uniqueIdentifier==='campaign'){
            this.defaultCustomerValues.campaignId=recordId;
            this.defaultCustomerValues.campaignName=recordName;
        }

        // Handle For The Contact, Recurring and Campaign lookup for each row in table
        if( lookupDetail.uniqueIdentifier.includes('rowContact') || 
            lookupDetail.uniqueIdentifier.includes('rowCampaign') || 
            lookupDetail.uniqueIdentifier.includes('rowRecurring')
        )
        {
            let rowIndex=parseInt(lookupDetail.uniqueIdentifier.split('-')[1]);
            console.log('Identifier:',lookupDetail.uniqueIdentifier);
            console.log(rowIndex);
            console.log(recordId);
            console.log(recordName);

            let rowTemp=Object.assign({},this.giftrow.at(rowIndex));
            // Contact lookup             
            if(lookupDetail.uniqueIdentifier.includes('rowContact')){                
                rowTemp.contactName=recordName;
                rowTemp.contactId= recordId;
                rowTemp.contactRd=' npe03__Contact__c=\''+recordId+'\'';                         
            }
            // Campaign lookup
            if(lookupDetail.uniqueIdentifier.includes('rowCampaign')){                
                rowTemp.campaignName=recordName;
                rowTemp.campaignId= recordId;                         
            }
            // Recurring Donation Lookup
            if(lookupDetail.uniqueIdentifier.includes('rowRecurring')){                
                rowTemp.recurringName=recordName;
                rowTemp.recurringId= recordId;                         
            } 
            this.giftrow[rowIndex]=rowTemp;
            let tempGift=Object.assign({},this.giftrow.at(rowIndex));           
            console.log(tempGift); 
        }
        //console.log(JSON.stringify(this.giftrow));
                
    }   

    handleProceed(event){
        if((this.countOfGifts>0 && this.isRecurringDonationVisible == true) || ( this.expectedTotalAmount>0 && 
            this.countOfGifts>0 && this.isRecurringDonationVisible == false ) ){
            this.giftrow=[];   
            this.sumOfAmount = 0 ;
            for(let i=0;i<this.countOfGifts;i++){
                let defaultFields=Object.assign({},this.giftrowField);
                defaultFields.serialNo=i+1;
                defaultFields.contactIdentifier='rowContact-'+i;
                defaultFields.recurringIdentifier='rowRecurring-'+i;
                defaultFields.campaignIdentifier='rowCampaign-'+i;
                defaultFields.amount=this.defaultCustomerValues.amount;
                defaultFields.campaignId=this.defaultCustomerValues.campaignId;
                defaultFields.donationDate=this.defaultCustomerValues.donationDate;

                defaultFields.authCard='';
                this.giftrow=[...this.giftrow,defaultFields];
                this.sumOfAmount += parseInt(this.defaultCustomerValues.amount);
                console.log('### defaultFields = ' , defaultFields );
            }
            //console.log('### giftrow =  ' , JSON.stringify(this.giftrow));
            //console.log('### sumOfAmount =  ' , sumOfAmount);

        }else{
            this.showToast('!Error','Please enter the Expected Count Gift and Expected Total Batch Amount','error');
        }
        
    }

    handleAddRow(event){
        if(this.countOfGifts === 20){
            this.showToast('Error','You already added maximum row.','error');
        }else{
            
            let totalGiftRow=this.giftrow.length;
            this.countOfGifts=parseInt(this.countOfGifts)+1;
            let defaultFields=Object.assign({},this.giftrowField);
            defaultFields.serialNo=totalGiftRow+1;
            defaultFields.contactIdentifier='rowContact-'+totalGiftRow;
            defaultFields.recurringIdentifier='rowRecurring-'+totalGiftRow;
            defaultFields.campaignIdentifier='rowCampaign-'+totalGiftRow;
            defaultFields.amount=this.defaultCustomerValues.amount;
            defaultFields.campaignId=this.defaultCustomerValues.campaignId;
            defaultFields.donationDate=this.defaultCustomerValues.donationDate;
          
            defaultFields.authCard = '';
            this.giftrow=[...this.giftrow,defaultFields];
         
            var amount = 0;
            this.giftrow.forEach(function(gftRow){   amount += parseInt(gftRow.amount); })
            this.sumOfAmount = amount;
            
        }

        
    }
    
    get isRecurringDonationVisible(){
        let isVisisble=false;
        isVisisble=this.donationTypeValue==='Recurring'?true:false;
        return isVisisble;
    }

    async handleProcessCard(event){
        this.isSpinnerActive=true;
      if(!this.isValidValue(this.creditCardNumber) || !this.isValidValue(this.expiryMonth) || !this.isValidValue(this.expiryYear)){
        this.showToast('!Error','Required fields are missing','error');
        this.isSpinnerActive=false;
      }else{
        let cardPaymentResult=await this.cardPayment();
        cardPaymentResult=JSON.parse(cardPaymentResult);        
        //console.log('cardPaymentResult'+JSON.stringify(cardPaymentResult));        
        if( this.isValidValue(cardPaymentResult) && this.isValidValue(cardPaymentResult.card)){
            let fingerPrint=cardPaymentResult.card.fingerprint;            
            let tempGift=Object.assign({},this.giftrow.at(this.selectedIndex));
            tempGift.cardNumber=this.creditCardNumber;
            tempGift.expiryMonth=this.expiryMonth;
            tempGift.expiryYear=this.expiryYear;
            tempGift.idx=cardPaymentResult.id;
            tempGift.status=cardPaymentResult.status;
            tempGift.name=cardPaymentResult.card.name;
            tempGift.last4=cardPaymentResult.card.last4;
            tempGift.cardId=cardPaymentResult.card.id;
            tempGift.brand=cardPaymentResult.card.brand;
            tempGift.fingerprint=fingerPrint;
            this.giftrow[this.selectedIndex]=tempGift;            
            this.showToast('Success','Card Authorization Succesfully Completed ','success');
             
            //console.log('paymentRecordResult'+JSON.stringify(tempGift));
        }else{
            this.showToast('!Error','Please check the card detail or contact your administrator','error');
        }        
      }
      this.isSpinnerActive=false;
      this.handlePopUpCancel();

    }

    async handleProcessAllPayment(event){
        let totalExpectd=this.expectedTotalAmount;
        let totalAmount = this.giftrow.reduce((accumulator, object) => {
            return parseFloat(accumulator) + parseFloat(object.amount);
        }, 0);        
        
        if(totalAmount> totalExpectd && this.isRecurringDonationVisible==false){
            this.showToast('!Error','Total Amount should not be greater than Expected Total Amount','error');
        }else{
            let isError=false;
            this.giftrow.forEach((row, index) => {
                let tempRow=Object.assign({},row);
                if( !this.isValidValue(tempRow.contactId) || 
                    (!this.isValidValue(tempRow.donationDate) && this.isRecurringDonationVisible == false ) ||
                    (!this.isValidValue(tempRow.amount) && this.isRecurringDonationVisible == false )){
                        this.showToast('!Error','Please check for card authorization or mandatory fields ','error');
                        isError=true;
                        //tempRow.defaultClass='slds-hint-parent validation-error';
                        this.giftrow[index]=tempRow;
                }else{
                    //tempRow.defaultClass='slds-hint-parent';
                    this.giftrow[index]=tempRow; 
                }
            });
            if(!isError){
                this.isSpinnerActive=true;        
                let paymentRecordResult=await this.paymentRecord();
                console.log('paymentRecordResult'+JSON.stringify(paymentRecordResult));
                this.isSpinnerActive=false;
                if(this.isValidValue(paymentRecordResult)){
                    this.showToast('Success','Payment Save Succesfully Completed ','success');
                }
            }
        }
    }

    handleRowChange(event){
        let evenDetail=event.currentTarget.dataset.index;
        let fieldName=event.currentTarget.name;
        let eventValue=event.detail.value;
        //console.log('evenDetail'+fieldName+''+eventValue);
        let rowTemp=Object.assign({},this.giftrow.at(evenDetail));//[fieldName]=eventValue;
        rowTemp[fieldName]=eventValue;
        this.giftrow[evenDetail]=rowTemp;
        this.sumOfAmount = 0 ;
        var amount = 0;
       
        this.giftrow.forEach(function(gftRow){  amount += parseInt(gftRow.amount); });
        // console.log('---Donation Date'+JSON.stringify(this.giftrow));
        this.sumOfAmount = amount;
        
    }
    // Create Opportunity and Payment
    paymentRecord(){
        return new Promise((resolve, reject) => {
            createPaymentRecords({jsonString:JSON.stringify(this.giftrow)})
                .then(data => {
                    resolve(data);
                })
                .catch(error => {
                    this.showToast('!Error','Please contact your administrator : '+error.body.message,'error','sticky');
                    //console.log(error);
                });
        });               
    }

    get isAddRowVisible(){
        return this.giftrow.length>0?true:false;
    }

    isValidValue(val){
        return  val!==undefined && val !=='' && val!==null;
    }

    get isBathGiftEntyDisable(){
        return this.giftrow.length > 0;
    }

    get totalRowAmount(){
        let totalAmount =0;
        this.giftrow.forEach(element=>{
            totalAmount+=this.isValidValue(element.amount)?parseFloat(element.amount):0;
        });       
        return totalAmount;
    }

    handleClearAll(){
        this.isSpinnerActive=true;
        location.reload();
    }

    handleRemoveRow(event){
        this.isSpinnerActive=true;
        let index=event.currentTarget.dataset.index;
        this.giftrow.splice(index,1);
        this.isSpinnerActive=false;
    }
    
}