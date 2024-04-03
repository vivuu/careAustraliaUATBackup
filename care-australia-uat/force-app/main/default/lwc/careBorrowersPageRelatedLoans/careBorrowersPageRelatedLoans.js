import { LightningElement, track, api,wire } from 'lwc';
import PlusIC from '@salesforce/resourceUrl/PlusIconss';
import UpIcons from '@salesforce/resourceUrl/UpIconforBorrower';
import getLoanDetails from '@salesforce/apex/LWC_AllLoansCtrl.getLoanDetails';

import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import { publish,createMessageContext, subscribe } from 'lightning/messageService';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class CareBorrowersPageRelatedLoans extends LightningElement {
    context = createMessageContext();
    coverImage;
    view14 = false;
    showRepaySchedules = false;
    borrowerUrl;
    BorrowerUpIcon = UpIcons;
    repaymentSchedules=[];
    loanId;
    borrowerName;
    borrowerDescription;
    contributors;
    showCart = true;
    contributorsCount=12;
    showContributors=[];
    showRelatedLoans=false;
    showContributorsSection = false;
    spin=false;
    projectImpact = [];
    //Used to store loans information
    Loan_Title__c;
    loc;
    Loan_Type__c;
    Loan_Description__c;
    Funded__c;
    Loan_Term_Months__c;
    Loan_Schedule__c;
    Published_Amount_AUD__c;
    Amount_Funded__c;
    progressStyle;
    loanAmounts=[];
    displayPreviousButtom=false;
    displayNextButtom=true;
    @api contactid; //= '003AD00000Bs9xdYAB';
    @track currentloandetails;
    val1;
    val2;

    allLoansPage = window.location.href.substring(0, window.location.href.indexOf('/s')+3)+'careviewallloans';
    getUrlParamValue(url, key){
        return new URL(url).searchParams.get(key);
    }

    @wire(LWCSectionMetaData, { category: 'careborrowerspage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for Related loans');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Related loans") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Related in val1:', this.val1);
            console.log('@@@ loans in val2:', this.val2);

        } else if (error) {
            // Handle error
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
    handleDelete(loanId) {
    
        const matchingObjDataIndex = this.carouselItems.findIndex(
            objRecord => objRecord.Id == loanId
        );
        console.log('matchingObjDataIndex ', matchingObjDataIndex);
        // Check if a matching record was found in objdata
        if (matchingObjDataIndex !== -1) {
            // Update the isButtonVisible property to false
            this.carouselItems[matchingObjDataIndex].isButtonVisible = false;
            console.log('-->',this.carouselItems[matchingObjDataIndex].Lent, this.carouselItems[matchingObjDataIndex].selectedAmount);
            // var l = this.carouselItems[matchingObjDataIndex].Lent!=undefined ? this.carouselItems[matchingObjDataIndex].Lent.replaceAll('$',''):this.carouselItems[matchingObjDataIndex].Lent;
            this.carouselItems[matchingObjDataIndex].Lent = Number(this.carouselItems[matchingObjDataIndex].Lent) - Number(this.carouselItems[matchingObjDataIndex].selectedAmount);
            this.carouselItems[matchingObjDataIndex].Amount_Funded__c = this.carouselItems[matchingObjDataIndex].Lent;
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
            this.carouselItems = [...this.carouselItems]; // Force reactivity
        } 
    }
    checkOutToCart(){
        const message = {
            messageToSend: 'Checkout',
            currentRecordId:true
        };
        publish(this.context, CARTMC, message);
          
    }
    connectedCallback() {
        this.subscribeMC();
        var bUrl = window.location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.borrowerUrl = bUrl+'/careborrowers';
        //console.log('LoanId:');
        const tempId = 'loanId';//id
        this.loanId = atob(this.getUrlParamValue(window.location.href, tempId));
        //console.log( this.loanId);
        this.spin = true;
        var myAA = localStorage.getItem('myArray');
        var prevLoans = myAA != undefined && myAA != 'undefined' && myAA != ''? JSON.parse(myAA) : undefined;
        var previousLoans = [];
        if( prevLoans != undefined && prevLoans != 'undefined' ){
            previousLoans = prevLoans;
        }
        getLoanDetails({loanId:this.loanId})
        .then( result => {
            //console.log('result ', JSON.stringify(result));
            if( result!=undefined && result.Loan!=undefined && result.Loan.length > 0 ){
                //console.log('LoanAMT:',result.loanAmts);
                this.currentloandetails = result.Loan;
                console.log('result.Loan from borrowers page ', result.Loan)
                console.log('this.currentloandetails from borrowers page ', JSON.stringify(this.currentloandetails))
                var loanAmounts = result.loanAmts != undefined? result.loanAmts.split(';') : [];

                //console.log('Lo:',loanAmounts);
                var loan = result.Loan[0];

                var loanAmtLeftForFunding = result.Loan[0].Amount_Left_Before_Fully_Funded__c;
                var LoanAmounts = [];
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
                    if( !LoanAmounts.includes(Number(loanAmtLeftForFunding)) ){ //'$'+
                        LoanAmounts.push( loanAmtLeftForFunding );//'$'+
                    }
                }
                this.loanAmounts = LoanAmounts;
                var loanImages = result.LoanContentDis;
                var carouselImages = [];
                for( var val of loanImages ){
                    if( val.Name.includes('_cover_round') ){
                        this.coverImage = val.ContentDownloadUrl;
                    } else if( !val.Name.includes('_cover') ){
                        carouselImages.push( {'image':val.ContentDownloadUrl} );
                    }
                }
                if( loan.Stage__c=='Active' || loan.Amount_Left_Before_Fully_Funded__c==0 ){
                    this.showCart = false;
                }
                if( result.RelatedLoan != undefined && result.RelatedLoan.length>0 ){
                    var i = 0;
                    var relatedLoans = [];
                    var relDis = result.RelatedLoanContentDis;
                    //console.log('RELD:',relDis);
                    for( var val of result.RelatedLoan ){
                        val = val!=undefined ? JSON.parse(JSON.stringify(val)) : val;
                        i++;
                        var relCountry = val.Borrower__r !=undefined ? val.Borrower__r.City__c != undefined ?val.Borrower__r.City__c +'-'+val.Borrower__r.Country__c:val.Borrower__r.Country__c : '';
                        var imgUrl = relDis!=undefined && relDis[val.Id]!=undefined && relDis[val.Id].length>0 ? relDis[val.Id][0].ContentDownloadUrl : '';
                        var progressStyle = '';
                        var len = val.Funded__c!= undefined ? val.Funded__c : 0;
                        var fundLen = len!=undefined && len >= 90 ? len-1 : len;
                        if( val.Funded__c!= undefined && val.Funded__c > 85 ){
                            progressStyle = 'background-color: #2a871f; width:'+fundLen+'%;';
                        } else{
                            progressStyle = 'background-color: #ffd700;width:'+fundLen+'%;';
                        }
                        var amtLeftForFunding = val.Amount_Left_Before_Fully_Funded__c==undefined?val.Published_Amount_AUD__c:val.Amount_Left_Before_Fully_Funded__c;
                        var relLoanAmounts = [];
                        if( amtLeftForFunding!=undefined ){
                            var i = 0;
                            while( i< loanAmounts.length ){
                                console.log('LL:',loanAmounts[i]);
                                if(loanAmounts[i]==''){ 
                                    i++;
                                    continue;
                                }
                                var v = Number(loanAmounts[i]);
                                if(v<=amtLeftForFunding){
                                    relLoanAmounts.push( v );
                                    i++;
                                }else{
                                    break;
                                }
                            }
                            if( !relLoanAmounts.includes(amtLeftForFunding) ){
                                relLoanAmounts.push( amtLeftForFunding );
                            }
                            if( !relLoanAmounts.includes(0) ){
                                relLoanAmounts.unshift(0);    
                            }
                        }/* 
                        var lAmts = [];
                        var selAmt = 0;
                        for( var v of relLoanAmounts ){
                            var sel = false;
                            if( selAmt!=undefined && v == selAmt ){
                                sel = true;
                            }
                            lAmts.push({label:v, selected:sel});
                        }
                        val.loanAmounts = lAmts; */
                        const itemIndex = previousLoans.findIndex(item => item.Id === val.Id);
                        var isButtonVisible = false;
                        var selAmt = 25;
                        if( itemIndex != -1 && itemIndex != undefined ){
                            isButtonVisible = true;
                            selAmt = previousLoans[itemIndex].selectedAmount;
                            /* var per = val.Amount_Funded__c+previousLoans[itemIndex].progress;
                            obj.progress = per != undefined? 'width:'+per+'%;': 'width:0;';
                            if(per > 85){
                                obj.progress+=' background-color:#2a871f;';
                            } */
                            val.Amount_Funded__c = val.Amount_Funded__c==undefined?0:Number(val.Amount_Funded__c);
                            var amtFF = val.Amount_Funded__c==undefined?0:Number(val.Amount_Funded__c);
                            val.Amount_Funded__c =  amtFF+ Number(previousLoans[itemIndex].Funded__c);
                            selAmt = Number(previousLoans[itemIndex].Funded__c) || 25;
                            console.log('ss:',selAmt);
                            var per = (Number(val.Amount_Funded__c) / Number(val.Published_Amount_AUD__c)) * 100;
                            if( per!= undefined && per > 85 ){
                                progressStyle = 'background-color: #2a871f; width:'+per+'%;';
                            } else{
                                progressStyle = 'background-color: #ffd700;width:'+per+'%;';
                            }
                        }
                        var lAmts = [];
                        for( var v of relLoanAmounts ){
                            var sel = false;
                            if( selAmt!=undefined && v == selAmt ){
                                sel = true;
                            }
                            lAmts.push({label:v, selected:sel});
                        }
                        // var loanAmounts = lAmts;
                        // console.log('lAmts:',lAmts);
                        //
                        var dis = false;
                        if( val.Amount_Funded__c == val.Published_Amount_AUD__c ){
                            dis = true;
                        }
                        var obj = {
                            'Id':val.Id,
                            'progressStyle':progressStyle,
                            'id': i,
                            'loanAmts':lAmts,
                            'imageUrl': `background-image: url('${imgUrl}');background-size: cover; background-repeat: no-repeat;`,
                            'title': val.Loan_Title__c!=undefined && val.Loan_Title__c.length>50 ?val.Loan_Title__c.substring(0,51)+'...':val.Loan_Title__c,
                            'Loan_Title__c': val.Loan_Title__c,
                            'location' : relCountry,
                            'Country__c' : relCountry,
                            //'description': val.LWC_Loan_Description__c != undefined && val.LWC_Loan_Description__c !='' ? val.LWC_Loan_Description__c.length > 40 ? val.LWC_Loan_Description__c.substring(0, 40) + "..." : val.LWC_Loan_Description__c: val.Loan_Description__c!=undefined?val.Loan_Description__c.length > 40 ? val.Loan_Description__c.substring(0, 40) + "..." : val.Loan_Description__c : '',
                            'description': val.Loan_Purpose__c != undefined && val.Loan_Purpose__c !='' ? val.Loan_Purpose__c.length > 80 ? val.Loan_Purpose__c.substring(0, 80) + "..." : val.Loan_Purpose__c: val.Loan_Purpose__c!=undefined?val.Loan_Purpose__c.length > 80 ? val.Loan_Purpose__c.substring(0, 80) + "..." : val.Loan_Purpose__c : '',
                            // val.Loan_Description__c!=undefined? val.Loan_Description__c.length > 40 ? val.Loan_Description__c.substring(0, 40) + "..." : val.Loan_Description__c : '',
                            'Lent': val.Amount_Funded__c!=undefined?val.Amount_Funded__c : 0,
                            'Goal': val.Published_Amount_AUD__c!=undefined?'$'+parseFloat(val.Published_Amount_AUD__c).toFixed(2) : '',
                            'Button': val.Loan_Type__c,
                            'readMoreLink' : this.borrowerUrl + '?loanId='+btoa(val.Id),
                            'isButtonVisible':isButtonVisible,
                            'selectedAmount':selAmt,
                            'disable':dis
                        };
                        relatedLoans.push( obj );
                    }
                    if( relatedLoans.length > 0 )   this.showRelatedLoans = true;
                    this.carouselItems = relatedLoans;
                }
            } 
            
            setTimeout(() => {
                this.spin = false;
            }, 3000);
        }).catch( err=>{
            console.log('Error : ',err);
            this.spin = false;
        } )
    }
    checkout=false;
    loanIdsToCart=[];
    myArray=[];
    currentRecordId;
    cart=[];
    amountAddedToCart=0;
    handleChangeSelect( event ){
        var idx = event.target.dataset.index;
        var val = event.target.value;
        val = val.replaceAll('$','');
        this.carouselItems[idx].selectedAmount = Number(val);
        console.log(val);

        
            const updatedItem = { ...this.carouselItems[idx] };
            updatedItem.isButtonVisible = false;
            updatedItem.fundingOptions = updatedItem.loanAmts.map(option => {
                        option.selected = option.label == Number(val);
                        return option;
                    });
            console.log('after changed the option value ', JSON.stringify(updatedItem.fundingOptions))
            // Create a new array with the updated item
            const updatedItems = [...this.carouselItems];
            updatedItems[idx] = updatedItem;

            // Update the items array with the new array containing the updated item
            this.carouselItems = updatedItems;
        
       


      }
    addToCart(event) {
        try{
          /* this.disabledButton = true;
          this.selectDisabled = true; */
          setTimeout(() => this.timeOut(), 8000);
          const itemId = event.currentTarget.dataset.id;
          let indexValueForButton = event.target.dataset.id;
          this.loanIdsToCart.push(itemId);
          console.log('event.target.dataset.id ',event.target.dataset.id)
          console.log('this.carouselItems[index].Id ',this.carouselItems[event.target.dataset.id].Id)
          const currentRecordItem = this.carouselItems[event.target.dataset.id];
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
            //Loan added to cart
              currentRecordItem.TransactionId=result[0].Id;
              currentRecordItem.isButtonVisible = true;
      
              if(result[0].Id.length >=15 || result[0].Id.length>=18){
                  if (!isNaN(indexValueForButton) && indexValueForButton >= 0 && indexValueForButton < this.carouselItems.length) {
                    //console.log('inside if ')
                    var amt = currentRecordItem.Lent!=undefined ? Number(currentRecordItem.Lent): 0;
                    var goal = currentRecordItem.Goal!=undefined ? Number(currentRecordItem.Goal.replaceAll('$','')): 0;
                    console.log( 'AMT:',amt );
                    console.log( 'AMT:',goal );
                    console.log( 'AMT:',currentRecordItem.Lent );
                    console.log( 'AMT:',currentRecordItem.Goal );
                    currentRecordItem.Lent = Number(amt)+ Number(currentRecordItem.selectedAmount);
                    currentRecordItem.Amount_Funded__c = Number(amt)+ Number(currentRecordItem.selectedAmount);
                    var per = (Number(currentRecordItem.selectedAmount) / Number(goal)) * 100;
                    currentRecordItem.progress = per;
                    currentRecordItem.Funded__c = currentRecordItem.selectedAmount;
                    currentRecordItem.Loan_Title__c = currentRecordItem.title;
                    currentRecordItem.Loan_Type__c = currentRecordItem.Button;
                    currentRecordItem.Country__c = currentRecordItem.location;
                    currentRecordItem.Published_Amount_AUD__c = Number((currentRecordItem.Goal).replace('$',''));
                    
                    currentRecordItem.Funded = currentRecordItem.Amount_Funded__c;
                    currentRecordItem.progressBar = (currentRecordItem.Funded / currentRecordItem.Published_Amount_AUD__c) *100;
                    currentRecordItem.fundingOptions = currentRecordItem.loanAmts;
                    console.log('current record item ',currentRecordItem);
                    /* if(per > 85){
                      currentRecordItem.progress+=' background-color:#2a871f;';
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
                  // Store the array in local storage
                  console.log('Irmm:',JSON.stringify(previousLoans));
                  localStorage.setItem('myArray', JSON.stringify(previousLoans));
                  this.publishMC();   
      
      
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
                      /* var per = (Number(currentRecordItem.amountFunded) / Number(currentRecordItem.Published_Amount_AUD__c)) * 100;
                      updatedItem.progress = 'width:'+per+'%;';
                      updatedItem.selectedAmount = pageData['Amount__c'];
                      if(per > 85){
                        updatedItem.progress+=' background-color:#2a871f;';
                      } */
                      var per = (Number(currentRecordItem.Lent) / Number(goal)) * 100;
                        if( per!= undefined && per > 85 ){
                            updatedItem.progressStyle = 'background-color: #2a871f; width:'+per+'%;';
                        } else{
                            updatedItem.progressStyle = 'background-color: #ffd700;width:'+per+'%;';
                        }
                      // Create a new array with the updated item
                      const updatedItems = [...this.carouselItems];
                      updatedItems[itemIndex] = updatedItem;
                      console.log('updatedItems ', updatedItems);
      
                      // Update the items array with the new array containing the updated item
                      this.carouselItems = updatedItems;
      
                  }
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
// img3=img3;
@track screenWidth;
@track screenHeight;
@api slidesData;
// CarouselBan = CarBanner;
Plus = PlusIC;
slides=[];
errorMessageOnTransaction;
  errorTransaction=false;
closeErrorPopup(){
    this.errorTransaction = false;
    this.errorMessageOnTransaction = '';
  }

/* slides=[
        {
            image: `${slide3}`,
            title: 'Textile & Garment Upgrade',
            location : 'Vitenam',
            description: 'Parichat is requesting TB67988.82 ($1600) for a new cutting table, overlocker, workplace training for her new staff and to implement a workplace health and safety plan for her business.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Garment Factory'
        },
        {
            image: `${slide2}`,
            title: 'Education Start-Up',
            location : 'Vitenam',
            description: 'Parichat is requesting TB67988.82 ($1600) for a new cutting table, overlocker, workplace training for her new staff and to implement a workplace health and safety plan for her business.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Education'
        },
        {
            image: `${slide3}`,
            title: 'Sustainable Agriculture',
            location : 'Vitenam',
            description: 'Parichat is requesting TB67988.82 ($1600) for a new cutting table, overlocker, workplace training for her new staff and to implement a workplace health and safety plan for her business.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Garment Factory'
        },
        {
            image: `${slide2}`,
            title: 'Emergency Preparation',
            location : 'Vitenam',
            description: 'Parichat is requesting TB67988.82 ($1600) for a new cutting table, overlocker, workplace training for her new staff and to implement a workplace health and safety plan for her business.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Garment Factory'
        },
        
    ] */

    

@track carouselItems=[];



@track currentSlideIndex = 0;
    @track visibleSlides = 4;

    get sliderStyles() {
        const translateXValue = this.currentSlideIndex * (100 / this.visibleSlides);
        return `transform: translateX(-${translateXValue}%);`;
    }

    get visibleCarouselItems() {
        return this.carouselItems.slice(this.currentSlideIndex, this.currentSlideIndex + this.visibleSlides);
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
        if (this.currentSlideIndex < (8 - this.carouselItems.length)) { //this.carouselItems.length - this.visibleSlides
            this.currentSlideIndex++;
            this.displayPreviousButtom=true;
        }else{
            this.displayNextButtom=false;
        }
    }

    handleDotClick(event) {
        const index = event.target.dataset.index;
        this.currentSlideIndex = parseInt(index);
    }

      get getcarbackImage() {
      return `background-image: url('${this.CarouselBan}');background-size: cover; background-repeat: no-repeat;`;
  }

  viewMoreContributors(){
    this.showContributors = this.contributors;
    this.view14 = false;
  }

  handleViewMoreTransaction(){
    const currentPageUrl = window.location.href;
    var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s')+3);
    window.location.href = currentPageUrl2+'careallloanschedules?loanId='+btoa(this.loanId);
  }
    scrolltoTop() {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }


  
}