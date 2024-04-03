import { LightningElement, api } from 'lwc';
import getLoanDetails from '@salesforce/apex/LWC_AllLoansCtrl.getLoanDetails';
import { publish,createMessageContext, subscribe } from 'lightning/messageService';
import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import cartIcon from '@salesforce/resourceUrl/cartIcon';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
export default class AddLoan extends LightningElement {
    cartIcon = cartIcon;
    @api loanamt;
    errorTransaction =false;
    errorMessageOnTransaction = '';
    @api loanId;
    @api contactid;
    selectedAmount=25;
    @api currentloandetails=[];
    isButtonVisible = false;
    loanDetails=[];
    rendered = false;
    selectedAmt = 25;
    amtFunded=0;
    pubAmt=0;
    renderedCallback(){
        if( !this.loanamt != undefined && !this.rendered && this.loanamt.length > 0 ){
            var lAmts = [];
            console.log('sss:',this.selectedAmt);
            console.log(';;',JSON.parse(JSON.stringify(this.loanamt)));
            for( var v of this.loanamt ){
                var sel = false;
                if( this.selectedAmt!=undefined && Number(v) == Number(this.selectedAmt) ){
                    sel = true;
                }
                lAmts.push({label:v, selected:sel});
            }
            this.loanamt = lAmts;
            console.log('this.loanamt-- ',this.loanamt)
            this.rendered = true;
        }
    }
    connectedCallback() {
        //code
        console.log('api contactid ', this.contactid)
        console.log('currentloandetails from addloan ', JSON.stringify(this.currentloandetails));
        this.getLoanInfo();
        this.subscribeMC();
    }
    getLoanInfo(){
        var myAA = localStorage.getItem('myArray');
        var prevLoans = myAA != undefined && myAA != 'undefined' && myAA != ''? JSON.parse(myAA) : undefined;
        var previousLoans = [];
        if( prevLoans != undefined && prevLoans != 'undefined' ){
            previousLoans = prevLoans;
        }
        getLoanDetails({loanId:this.loanId})
            .then( result => {
                if( result!=undefined && result.Loan!=undefined && result.Loan.length > 0 ){
                    var obj = {};
                    var loans = JSON.parse(JSON.stringify(result.Loan));
                    for( var val in loans ){
                        console.log('cld:',val, result.Loan[val]);
                        obj[val] = result.Loan[val];
                    }
                    //Cart
                    const itemIndex = previousLoans.findIndex(item => item.Id === obj[0].Id);
                    var isButtonVisible = false;
                    var selAmt = 0;
                    if( itemIndex != -1 && itemIndex != undefined ){
                        isButtonVisible = true;
                        // selAmt = previousLoans[itemIndex].selectedAmount;
                        // obj[0].Amount_Funded__c = Number(obj[0].Amount_Funded__c) + Number(previousLoans[itemIndex].Funded__c);
                        selAmt = Number(previousLoans[itemIndex].Funded__c);
                        console.log('ss:',selAmt);
                        //var per = (Number(obj[0].Amount_Funded__c) / Number(obj[0].Published_Amount_AUD__c)) * 100;
                        /* if( per!= undefined && per > 85 ){
                            progressStyle = 'background-color: #2a871f; width:'+per+'%;';
                        } else{
                            progressStyle = 'background-color: #ffd700;width:'+per+'%;';
                        } */
                    }
                    this.selectedAmt = 25;
                    this.isButtonVisible = isButtonVisible;
                    /* var lAmts = [];
                    for( var v of relLoanAmounts ){
                        var sel = false;
                        if( selAmt!=undefined && v == selAmt ){
                            sel = true;
                        }
                        lAmts.push({label:v, selected:sel});
                    } */
                    this.loanDetails = obj;
                    console.log('obj[0]',obj[0]);
                    this.amtFunded = obj[0].Amount_Funded__c!=undefined?obj[0].Amount_Funded__c:0;
                    var p = ((Number(this.amtFunded)+Number(selAmt)) / Number(obj[0].Published_Amount_AUD__c)) * 100;
                    console.log('PPPP:',p);
                    this.passCurrencyProgress(Number(this.amtFunded)+Number(selAmt), p);
                    console.log('LOANAN:',this.loanamt);
                    this.pubAmt = obj[0].Published_Amount_AUD__c;
                }
            }).catch( err=>{
                console.log('Error : ',err);
                this.spin = false;
            } )
    }
    closeErrorPopup(){
        this.errorTransaction = false;
        this.errorMessageOnTransaction = '';
        
    }
//Cart Functionality

    checkout=false;
    loanIdsToCart=[];
    myArray=[];
    currentRecordId;
    cart=[];
    amountAddedToCart=0;
    context = createMessageContext();
    subscription;
    val = 25;
    fundingOptions=[];
    handleChangeSelect( event ){
        try{
            console.log('Hello');
            console.log(event.target.value);
            this.val = event.target.value;
            // val = val.replaceAll('$','');
            this.loanDetails.selectedAmount = Number(this.val);
            console.log(this.val);
            this.loanamt = this.loanamt.map(option => {
                    option.selected = option.label == this.val;
                    return option;
                });
            console.log('after change the selected value ', JSON.stringify(this.loanamt))

        }catch(e){
            console.log(e);
        }
    }
    addToCart(event) {
        try{
          setTimeout(() => this.timeOut(), 8000);
          var currentRecordItem = JSON.parse(JSON.stringify(this.loanDetails[0]));
          this.loanDetails.selectedAmount = Number(this.val);
          var selAmt = this.loanDetails.selectedAmount;
          console.log('CCC:',currentRecordItem);
          var pageData = {};
          pageData['Amount__c'] = Number(selAmt);
          pageData['Type__c'] = 'Loan';
          pageData['Loan__c'] = currentRecordItem.Id;
      
      
          console.log('this pagedata to apex ', JSON.stringify(pageData))
      
          const currentPageData = [pageData];
          console.log('before apex call ')
          createTransactionRecord({recordsToInsert: currentPageData})
          .then(result => {
            //Loan added to cart
              currentRecordItem.TransactionId=result[0].Id;
              this.isButtonVisible = true;
      
              if(result[0].Id.length >=15 || result[0].Id.length>=18){
                var amt = currentRecordItem.Amount_Funded__c!=undefined ? Number(currentRecordItem.Amount_Funded__c): 0 ;
                amt=parseFloat(Number(amt) + Number(currentRecordItem.Expected_Fund_From_Cart__c!=undefined?parseFloat(currentRecordItem.Expected_Fund_From_Cart__c).toFixed(2) : 0)).toFixed(2);
                var goal = currentRecordItem.Published_Amount_AUD__c!=undefined ? Number(currentRecordItem.Published_Amount_AUD__c): 0;
                currentRecordItem.Funded__c = Number(amt);
                currentRecordItem.Amount_Funded__c = Number(amt)+ Number(selAmt);
                
                //To show in cart percentage
                var per = (Number(selAmt) / Number(goal)) * 100;
                console.log('SSSEEE:',selAmt, goal);
                currentRecordItem.progress = per;
                currentRecordItem.Funded__c = selAmt;
                var country = currentRecordItem.Borrower__r !=undefined ? currentRecordItem.Borrower__r.City__c != undefined ?currentRecordItem.Borrower__r.City__c +'-'+currentRecordItem.Borrower__r.Country__c:currentRecordItem.Borrower__r.Country__c : '';
                currentRecordItem.Country__c = country;
                var myAA = localStorage.getItem('myArray');
                var prevLoans = myAA != undefined && myAA != 'undefined' && myAA != ''? JSON.parse(myAA) : undefined;
                var previousLoans = [];
                if( prevLoans != undefined && prevLoans != 'undefined' ){
                    previousLoans = prevLoans;
                }
                var mainLoanProgress = ( currentRecordItem.Amount_Funded__c / goal )* 100;
                currentRecordItem.selectedAmount = selAmt;
                currentRecordItem.fundingOptions = this.loanamt;
                currentRecordItem.Funded = Number(amt) + Number(selAmt);
                currentRecordItem.progressBar = (currentRecordItem.Funded / goal)*100;
                // currentRecordItem.progress = per;
                previousLoans.push( currentRecordItem );
                this.currentRecordId = previousLoans;
                this.amountAddedToCart = this.amountAddedToCart + 1;
                console.log('send to cart items--> ',currentRecordItem)
                localStorage.setItem('myArray', JSON.stringify(previousLoans));
                this.publishMC();   
                this.loanDetails = currentRecordItem;
                this.passCurrencyProgress( currentRecordItem.Amount_Funded__c, mainLoanProgress );
                this.amtFunded = amt;
                this.pubAmt = goal;
                
              }
          })
          .catch(error =>{
              console.log('error from transaction record insert ', error)
              console.log('error.body.pageErrors[0].message ', error.body.pageErrors[0].message)
                  this.errorTransaction = true;
                  this.errorMessageOnTransaction = error.body.pageErrors[0].message;
              
          }) 
        } catch( err ){
          console.log(err);
        }
    
      }

    publishMC() {
        const message = {
            messageToSend: 'AddToCart',
            currentRecordId:this.currentRecordId,
            amountAddedToCart: this.amountAddedToCart
        };
        publish(this.context, CARTMC, message);
    }
    subscribeMC() {
        if (this.subscription) {
            return;
        }
        this.subscription = subscribe(this.context, CARTMC, (message) => {
            this.displayMessage(message);
        });
    }
    displayMessage(message) {
        console.log('Our Loans');
        var eventValues = message ? JSON.stringify(message, null, '\t') : undefined;
        if( eventValues != undefined ){
            eventValues = JSON.parse( eventValues );
            console.log( eventValues.messageToSend );
            console.log( eventValues.currentRecordId );
            console.log( eventValues.amountAddedToCart );
            if( eventValues.messageToSend!='AddToCart' && eventValues.messageToSend == 'NavBar' ){
                this.handleDelete( eventValues.currentRecordId );
            }
        }
        // this.handleCart();
    }
    handleDelete(loanId) {
    
        // Check if a matching record was found in objdata
        if (loanId == this.loanId) {
            // Update the isButtonVisible property to false
            this.isButtonVisible = false;
            var lAmts = [];
            console.log('sss:',this.selectedAmt);
            
            console.log(';;',JSON.parse(JSON.stringify(this.loanamt)));
            var lAmounts = [];
            for( var v of this.loanamt ){
                lAmounts.push( v );
            }
            this.loanamt = [];
            for( var v of lAmounts ){
                var sel = false;
                if( Number(v.label) == 25 ){
                    sel = true;
                }
                lAmts.push({label:v.label, selected:sel});
            }
            this.amtFunded = this.amtFunded == undefined || this.amtFunded == 0 ? 0: this.amtFunded-this.selectedAmount;
            console.log('{{',this.amtFunded, this.pubAmt);
            var p = (Number(this.amtFunded) / Number(this.pubAmt))*100;
            this.passCurrencyProgress( this.amtFunded, p );
            this.selectedAmt = 25;
            this.loanamt = lAmts;
            console.log('LoanAmt:',lAmts);
            /* this.carouselItems[matchingObjDataIndex].Lent = Number(this.carouselItems[matchingObjDataIndex].Lent) - Number(this.carouselItems[matchingObjDataIndex].selectedAmount);
            console.log(JSON.parse(JSON.stringify(this.carouselItems[matchingObjDataIndex])));
            console.log('AAA:',this.carouselItems[matchingObjDataIndex].Lent, this.carouselItems[matchingObjDataIndex].Goal);
            var g = this.carouselItems[matchingObjDataIndex].Goal;
            g = g.replaceAll('$','');
            var per = (Number(this.carouselItems[matchingObjDataIndex].Lent) / Number(g)) * 100;
            console.log('Per:',per);
            this.carouselItems[matchingObjDataIndex].progressStyle = 'width:'+per+'%;';
            currentRecordItem.Funded__c = per;
            if(per > 85){
              this.carouselItems[matchingObjDataIndex].progressStyle+=' background-color:#2a871f;';
            } else{
              this.carouselItems[matchingObjDataIndex].progressStyle+=' background-color:#ffd700';
            }
            // Trigger any necessary component updates
            this.carouselItems = [...this.carouselItems]; // Force reactivity */
        } 
    }
    checkOutToCart(){
        const message = {
            messageToSend: 'Checkout',
            currentRecordId:true
        };
        publish(this.context, CARTMC, message);     
    }
    passCurrencyProgress( selAmt, progressWidth ){
        this.dispatchEvent( new CustomEvent( 'currprogresschange', {detail: {amtFunded:selAmt, progress:progressWidth }} ) );
    }
}