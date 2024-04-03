import { LightningElement,track, api, wire } from 'lwc';
import cartIcon from '@salesforce/resourceUrl/cartIcon';
import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import getAllLoansAndDoc_HomePage from '@salesforce/apex/LWC_AllLoansCtrl.getAllLoansAndDoc_HomePage';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import { publish,createMessageContext, subscribe } from 'lightning/messageService';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
export default class Lwr_careHomePage_ourLoans extends LightningElement {
    cartIcon = cartIcon;
    val1;
    val2;
    showLoans = false;
    context = createMessageContext();
    @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;
    @api slidesData;
    borrowerUrl;
    link;
    imageUrl;
    minimumLendingAmount;
    displayPreviousButtom=false;
    displayNextButtom=true;
    @track carouselItems = [];
    @track firstFourItems = [];
    @track currentSlideIndex = 0;
    @track visibleSlides = 4;
    loanAmounts;
    currentRecordId=[];
    amountAddedToCart=0;
    cart=[];
    checkout=false;
    loanIdsToCart=[];
    myArray=[];
    get sliderStyles() {
        const translateXValue = this.currentSlideIndex * (112 / this.visibleSlides);
        return `transform: translateX(-${translateXValue}%);`;
    }

    get visibleCarouselItems() {
        return this.carouselItems.slice(this.currentSlideIndex, this.currentSlideIndex + this.visibleSlides);
    }
    @wire(LWCSectionMetaData, {category:'homepage'})
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            // var val1 = '';
            // var val2 = '';

            for (let i = 0; i < data.length; i++) {
                if(data[i].MasterLabel=="OurLoans"){
                    this.val1= data[i].Value_1__c;
                    this.val2= data[i].Value_2__c;
                }
            }
            console.log('@@@ val1:',this.val1);
            console.log('@@@ val2:',this.val2);
            
            
            //obj.white = va1;
            //obj.yellow = va2;
            //a.push(obj);
            //obj = {};
            //this.categoryarr = a;

            //var categoryarr = {'value1':data[2].Value_1__c};
            //console.log('@@@ categoryarr :', this.categoryarr);

             } else if (error) {
            // Handle error
        }
    }
    previousSlide() {
        if (this.currentSlideIndex > 0) {
            this.currentSlideIndex--;
            this.displayNextButtom=true;
        }else if(this.currentSlideIndex == 0){
            this.displayNextButtom=true;
            this.displayPreviousButtom=false;
        }else{
            this.displayPreviousButtom=false;
        }
    }

    nextSlide() {
      console.log('currentSlideIndex-->'+this.currentSlideIndex);
      console.log('this.carouselItems.length-->'+this.carouselItems.length);
        if (this.currentSlideIndex < this.carouselItems.length) {
            this.currentSlideIndex++;
            this.displayPreviousButtom=true;
            console.log('Inside if currentSlideIndex-->'+this.currentSlideIndex);
        }else{
            this.displayNextButtom=false;
        }
    }

    handleDotClick(event) {
        const index = event.target.dataset.index;
        this.currentSlideIndex = parseInt(index);
    } 
    
  connectedCallback() {
    this.subscribeMC();
    this.getScreenSize();
    // var bUrl = window.location.href;
    var bUrl = location.href;
    bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
    this.borrowerUrl = bUrl+'/careborrowers';
    window.addEventListener('resize', this.getScreenSize.bind(this));
    
    //this.getCMSContent();
   
  }
    @wire(getAllLoansAndDoc_HomePage) 
    allloanshomepage ({ error, data }){
      if(data){
          console.log('Loan:',data);
            var arr = [];
            if( data!=undefined && data.Loan != undefined ){
              var loans = data.Loan;
              var contentDistribution = data.ContentDistribution;
              if( loans == undefined || loans.length <= 0 ){
                this.showLoans = false;
              } else{
                this.showLoans = true;
              }
              var myAA = localStorage.getItem('myArray');
              var prevLoans = myAA != undefined && myAA != 'undefined' && myAA != ''? JSON.parse(myAA) : undefined;
              var previousLoans = [];
              if( prevLoans != undefined && prevLoans != 'undefined' ){
                previousLoans = prevLoans;
              }
              for( var loan of loans ){
                  var obj = {};
                  obj.Id = loan.Id;
                  //obj.description = loan.LWC_Loan_Description__c != undefined && loan.LWC_Loan_Description__c !='' ? loan.LWC_Loan_Description__c.length > 70 ? loan.LWC_Loan_Description__c.substring(0, 70) + "..." : loan.LWC_Loan_Description__c: loan.Loan_Description__c!=undefined?loan.Loan_Description__c.length > 70 ? loan.Loan_Description__c.substring(0, 70) + "..." : loan.Loan_Description__c : '';
                    obj.description = loan.Loan_Purpose__c != undefined && loan.Loan_Purpose__c !='' ? loan.Loan_Purpose__c.length > 80 ? loan.Loan_Purpose__c.substring(0, 80) + "..." : loan.Loan_Purpose__c: loan.Loan_Purpose__c!=undefined?loan.Loan_Purpose__c.length > 80 ? loan.Loan_Purpose__c.substring(0, 80) + "..." : loan.Loan_Purpose__c : '';
                    obj.title = loan.Loan_Title__c!=undefined && loan.Loan_Title__c.length>50 ?loan.Loan_Title__c.substring(0,51):loan.Loan_Title__c ;
                    obj.Loan_Title__c = loan.Loan_Title__c;
                    var country = loan.Borrower__r !=undefined ? loan.Borrower__r.City__c != undefined ?loan.Borrower__r.City__c +'-'+loan.Borrower__r.Country__c:loan.Borrower__r.Country__c : '';
                    obj.location = country;
                    obj.Country__c = country;
                    var cd = contentDistribution!=undefined ? contentDistribution[loan.Id]:undefined;
                    obj.Button = loan.Loan_Type__c;
                    obj.Loan_Type__c = loan.Loan_Type__c;
                    obj.readMoreLink = this.borrowerUrl + '?loanId='+btoa(loan.Id);
                    obj.amountFunded = Number(loan.Amount_Funded__c!=undefined?parseFloat(loan.Amount_Funded__c).toFixed(2):0)
                    + Number(loan.Expected_Fund_From_Cart__c!=undefined?parseFloat(loan.Expected_Fund_From_Cart__c).toFixed(2) : 0);
                    obj.publishedAmount = loan.Published_Amount_AUD__c!=undefined?'$'+parseFloat(loan.Published_Amount_AUD__c).toFixed(2):'$'+0;
                    obj.Published_Amount_AUD__c = loan.Published_Amount_AUD__c;
                    obj.progress = 'width:'+ ((obj.amountFunded / obj.Published_Amount_AUD__c)*100 > 98 ? 98 : 
                    (obj.amountFunded / obj.Published_Amount_AUD__c)*100) +'%;';
                    
                    
                    obj.isButtonVisible = false;
                    obj.disable = false;
                    if(((obj.amountFunded / obj.Published_Amount_AUD__c)*100) > 85){
                        obj.progress+=' background-color:#2a871f;';
                    } else{
                        obj.progress+=' background-color:#ffd700';
                    }
                    var pubAmt = loan.Published_Amount_AUD__c == undefined ? 0 : loan.Published_Amount_AUD__c;
                    var fundAmt =  Number(loan.Amount_Funded__c!=undefined?parseFloat(loan.Amount_Funded__c).toFixed(2):0)
                    + Number(loan.Expected_Fund_From_Cart__c!=undefined?parseFloat(loan.Expected_Fund_From_Cart__c).toFixed(2) : 0);
                    if( pubAmt == fundAmt ){
                      obj.disable = true; 
                    }
                    if( cd != undefined ){
                      obj.imageUrl = cd[0].ContentDownloadUrl;
                      obj.style = `background-image: url('${obj.imageUrl}');background-size: cover; background-repeat: no-repeat; background-position: center;`
                    }
                    obj.selectedAmount = 25;
                    var loanAmounts = data.loanAmts != undefined? data.loanAmts.split(';') : [];
                    //console.log('Lo:',loanAmounts);
                    var loanAmtLeftForFunding = loan.Amount_Left_Before_Fully_Funded__c;
                    var LoanAmounts = [];
                    console.log('AMTLEFT:',loanAmtLeftForFunding);
                    loanAmtLeftForFunding = loanAmtLeftForFunding== undefined ? pubAmt - fundAmt:loanAmtLeftForFunding;

                    if( loanAmtLeftForFunding!=undefined ){
                        var i = 0;
                        while( i< loanAmounts.length ){
                            if(loanAmounts[i]==''){ 
                                i++;
                                continue;
                            }
                            var v = Number(loanAmounts[i]);
                            if(v<=loanAmtLeftForFunding){
                                LoanAmounts.push( v ); //'$'+
                                i++;
                            }else{
                                break;
                            }
                        }
                        LoanAmounts.unshift(0);
                        // if( !LoanAmounts.includes(Number(loanAmtLeftForFunding)) ){ //'$'+
                        //     LoanAmounts.push( loanAmtLeftForFunding );//'$'+
                            
                        // }
                        if( !LoanAmounts.includes(Number(loanAmtLeftForFunding.toFixed(2))) ){ //'$'+
                          LoanAmounts.push( loanAmtLeftForFunding.toFixed(2) );//'$'+
                          
                      }
                    }
                    // obj.loanAmounts = LoanAmounts;
                    const itemIndex = previousLoans.findIndex(item => item.Id === obj.Id);
                    var selAmt=25;
                    console.log('ItemIdx:',itemIndex);
                    if( itemIndex != -1 && itemIndex != undefined ){
                      obj.isButtonVisible = true;
                      var per = loan.Funded__c+previousLoans[itemIndex].progress;
                      console.log('PERTT:',loan.Funded__c, previousLoans[itemIndex].progress, per);
                      obj.selectedAmount = previousLoans[itemIndex].selectedAmount;
                      obj.progress = per != undefined? 'width:'+per+'%;': 'width:0;';
                      if(per > 85){
                          obj.progress+=' background-color:#2a871f;';
                      } else{
                        obj.progress+=' background-color:#ffd700;';
                      }
                      obj.amountFunded = Number(fundAmt) + Number(previousLoans[itemIndex].selectedAmount);
                      selAmt = Number(previousLoans[itemIndex].Funded__c) || 25;
                    }
                    console.log('ss:',selAmt);
                    var lAmts = [];
                    for( var v of LoanAmounts ){
                      var sel = false;
                      if( selAmt!=undefined && v == selAmt ){
                          sel = true;
                      }
                      lAmts.push({label:v, selected:sel});
                    }
                    obj.loanAmounts = lAmts;
                    console.log('lAmts:',lAmts);
                    arr.push(obj); 
                    console.log('arr-- ',arr)
                  }
              // this.minimumLendingAmount = data.loanAmts;
              this.carouselItems = arr;
              this.firstFourItems = this.carouselItems.slice(0, 4);
              console.log('CI:', JSON.stringify(this.carouselItems));
            } else{
              this.showLoans = true;
            }
      }
      else{
          console.log('@@@ Error Occured in All Loans', error);
      }
  }
  handleChangeSelect( event ){
    var idx = event.target.dataset.index;
    var val = event.target.value;
    val = val.replaceAll('$','');
    this.carouselItems[idx].selectedAmount = Number(val);
    console.log(val);

    const itemIndex = this.carouselItems[idx];

        if (itemIndex !== -1) {
            // Create a copy of the item and update its isButtonVisible property
            const updatedItem = { ...this.carouselItems[idx] };
            updatedItem.isButtonVisible = false;
            updatedItem.loanAmounts = updatedItem.loanAmounts.map(option => {
                        option.selected = option.label == Number(val);
                        return option;
                    });
            console.log('after changed the option value ', JSON.stringify(updatedItem.loanAmounts))
            // Create a new array with the updated item
            const updatedItems = [...this.carouselItems];
            updatedItems[idx] = updatedItem;

            // Update the items array with the new array containing the updated item
            this.carouselItems = updatedItems;
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
  errorMessageOnTransaction;
  errorTransaction=false;
  addToCart(event) {
    try{
      this.disabledButton = true;
      this.selectDisabled = true;
      setTimeout(() => this.timeOut(), 8000);
      const itemId = event.currentTarget.dataset.id;
      let indexValueForButton = event.target.dataset.id;
      this.loanIdsToCart.push(itemId);
      console.log('event.target.dataset.id ',event.target.dataset.id)
      console.log('this.carouselItems[index].Id ',this.carouselItems[event.target.dataset.id].Id)
      const currentRecordItem = this.carouselItems[event.target.dataset.id];
      currentRecordItem.Funded = currentRecordItem.amountFunded+(Number(currentRecordItem.selectedAmount)>0? Number(currentRecordItem.selectedAmount):25);
      currentRecordItem.progressBar = (currentRecordItem.Funded / currentRecordItem.Published_Amount_AUD__c) *100;
      currentRecordItem.fundingOptions = currentRecordItem.loanAmounts;
      console.log(currentRecordItem.selectedAmount);
      var pageData = {};
      pageData['Amount__c'] = Number(currentRecordItem.selectedAmount);
      pageData['Type__c'] = 'Loan';
      pageData['Loan__c'] = currentRecordItem.Id;
  
  
      console.log('this pagedata to apex ', JSON.stringify(pageData))
  
      const currentPageData = [pageData];
      console.log('before apex call ')
      createTransactionRecord({recordsToInsert: currentPageData})
      .then(result => {
          //console.log('result ', JSON.stringify(result));
          //console.log('currentRecordItem.TransactionId after result ', result[0].Id)
          currentRecordItem.TransactionId=result[0].Id;
          currentRecordItem.isButtonVisible = true;
          //console.log('currentRecordItem.TransactionId after result ', currentRecordItem)
  
          if(result[0].Id.length >=15 || result[0].Id.length>=18){
              console.log('currentRecordItem ', currentRecordItem);
              console.log('len:',this.carouselItems.length,'-->',indexValueForButton);
              if (!isNaN(indexValueForButton) && indexValueForButton >= 0 && indexValueForButton < this.carouselItems.length) {
                //console.log('inside if ')
                var amt = currentRecordItem.amountFunded;
                currentRecordItem.amountFunded = Number(amt)+ Number(currentRecordItem.selectedAmount);
                //console.log('-->',currentRecordItem.amountFunded, amt);
                //console.log('-->',currentRecordItem.Published_Amount_AUD__c);
                var per = (Number(currentRecordItem.selectedAmount) / Number(currentRecordItem.Published_Amount_AUD__c)) * 100;
                console.log('Per:',per);
                currentRecordItem.progress = per;
                currentRecordItem.Funded = currentRecordItem.amountFunded;//+(Number(currentRecordItem.selectedAmount)>0? Number(currentRecordItem.selectedAmount):25);
                currentRecordItem.progressBar = (currentRecordItem.Funded / currentRecordItem.Published_Amount_AUD__c)*100;
                /* if(per > 85){
                  currentRecordItem.progress+=' background-color:#2a871f;';
                } else{
                  currentRecordItem.progress+=' background-color:#ffd700';
                } */
              }
              var myAA = localStorage.getItem('myArray');
              var prevLoans = myAA != undefined && myAA != 'undefined' && myAA != ''? JSON.parse(myAA) : undefined;
              var previousLoans = [];
              if( prevLoans != undefined && prevLoans != 'undefined' ){
                console.log('prevLoans:',prevLoans);
                previousLoans = prevLoans;
              }
              previousLoans.push( currentRecordItem );
              this.currentRecordId = previousLoans;
              console.log('currentRecordItem after copying ', this.currentRecordId)
  
              this.amountAddedToCart = this.amountAddedToCart + 1; //this.currentRecordId.length;
              console.log('before pushing to cart localstorage ', this.cart)
              this.cart.push(this.currentRecordId);
              console.log('after pushing to cart localstorage ', this.cart)
              // this.myArray.push(currentRecordItem);
              // Store the array in local storage
              console.log('Irmm:',JSON.stringify(previousLoans));
              localStorage.setItem('myArray', JSON.stringify(previousLoans));
              this.publishMC();    
              // const childComponent = this.template.querySelector('c-care-nav-bar');
              //console.log('before if (childComponent)')
              /* if (childComponent) {
                  
                  this.myArray.push(currentRecordItem);
  
                  // Store the array in local storage
                  localStorage.setItem('myArray', JSON.stringify(this.myArray));
  
                  childComponent.loanidfromparent = this.currentRecordId; 
                  //childComponent.loanidfromparent = currentRecordItem;         
                  childComponent.startTimer();
                  childComponent.calculateTotalAmount();
                  //console.log('childComponent.loanidfromparent----> ', JSON.stringify(childComponent.loanidfromparent))
              }
              console.log('after if (childComponent)') */
              console.log('indexValueForButton ', indexValueForButton)
  
  
              // this will change the button to checkout from addtocart
              const itemId = this.carouselItems[indexValueForButton].Id;
              console.log('clicked items id --> ', itemId);
  
              // Find the clicked item index in the array
              const itemIndex = this.carouselItems.findIndex(item => item.Id === itemId);
              console.log('itemIndex ', itemIndex);
  
              if (itemIndex !== -1) {
                  console.log('inside if  itemIndex !== -1 ', itemIndex);
                  // Create a copy of the item and update its isButtonVisible property
                  const updatedItem = { ...this.carouselItems[itemIndex] };
                  updatedItem.isButtonVisible = true;
                  var per = (Number(currentRecordItem.amountFunded) / Number(currentRecordItem.Published_Amount_AUD__c)) * 100;
                  updatedItem.progress = 'width:'+per+'%;';
                  updatedItem.selectedAmount = pageData['Amount__c'];
                  if(per > 85){
                    updatedItem.progress+=' background-color:#2a871f;';
                  } else{
                    updatedItem.progress+=' background-color:#ffd700';
                  }
                  // Create a new array with the updated item
                  const updatedItems = [...this.carouselItems];
                  updatedItems[itemIndex] = updatedItem;
                  console.log('updatedItems ', updatedItems);
  
                  // Update the items array with the new array containing the updated item
                  this.carouselItems = updatedItems;
  
              }
              /* if (!isNaN(indexValueForButton) && indexValueForButton >= 0 && indexValueForButton < this.carouselItems.length) {
                //console.log('inside if ')
                var amt = currentRecordItem.amountFunded;
                amt = amt.replaceAll('$','');
                this.carouselItems[indexValueForButton].amountFunded = Number(amt)+ Number(currentRecordItem.selectedAmount);
                var per = (Number(currentRecordItem.amountFunded) / Number(currentRecordItem.Published_Amount_AUD__c)) * 100;
                console.log('Per:',per);
                this.carouselItems[indexValueForButton].progress = 'width:'+per+'%';
                this.carouselItems[indexValueForButton].Funded__c = Number(currentRecordItem.selectedAmount);
                if(per > 85){
                  this.carouselItems[indexValueForButton].progress+=' background-color:#2a871f;';
                }//console.log('this.carouselItems[indexValueForButton].Funded__c ',this.carouselItems[indexValueForButton].Funded__c)
                this.carouselItems = [...this.carouselItems]; // Trigger a reactivity update
                //console.log('this.objdata ',this.objdata)
            } */
          }
      })
      .catch(error =>{
          console.log('error from transaction record insert ', error)
          // console.log('error.body.pageErrors[0].message ', error.body.pageErrors[0].message)
          if( error.body!=undefined && error.body.pageErrors!=undefined && error.body.pageErrors.length > 0 ){
            this.errorTransaction = true;
            this.errorMessageOnTransaction = error.body.pageErrors[0].message;
          }    
          
      })
    } catch( err ){
      console.log(err);
    }

  }
  closeErrorPopup(){
    this.errorTransaction = false;
    this.errorMessageOnTransaction = '';
  }
  checkOutToCart(){
    const message = {
        messageToSend: 'Checkout',
        currentRecordId:true
    };
    publish(this.context, CARTMC, message);
      
  }
  fromNavBar(event){
    console.log('from navbar ', event.detail);
    if(event.detail == true){
      document.body.style.overflow = 'auto';
    }
    else if(event.detail == false){
      document.body.style.overflow = 'hidden';
    }
  }
  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }
  handleDelete(loanId) {
    
    const matchingObjDataIndex = this.carouselItems.findIndex(
        objRecord => objRecord.Id == loanId
    );
    console.log('matchingObjDataIndex ', matchingObjDataIndex);
    // Check if a matching record was found in objdata
    if (matchingObjDataIndex !== -1) {
        // Update the isButtonVisible property to false
        this.carouselItems[matchingObjDataIndex].isButtonVisible = false;
        this.carouselItems[matchingObjDataIndex].amountFunded = this.carouselItems[matchingObjDataIndex].amountFunded - this.carouselItems[matchingObjDataIndex].selectedAmount;
        console.log(JSON.parse(JSON.stringify(this.carouselItems[matchingObjDataIndex])));
        var per = (Number(this.carouselItems[matchingObjDataIndex].amountFunded) / Number(this.carouselItems[matchingObjDataIndex].Published_Amount_AUD__c)) * 100;
        console.log('Per:',per);
        this.carouselItems[matchingObjDataIndex].progress = 'width:'+per+'%;';
        currentRecordItem.Funded__c = per;
        if(per > 85){
          this.carouselItems[matchingObjDataIndex].progress+=' background-color:#2a871f;';
        } else{
          this.carouselItems[matchingObjDataIndex].progress+=' background-color:#ffd700';
        }
        // Trigger any necessary component updates
        this.carouselItems = [...this.carouselItems]; // Force reactivity
    } 
  }
  subscription;
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
}