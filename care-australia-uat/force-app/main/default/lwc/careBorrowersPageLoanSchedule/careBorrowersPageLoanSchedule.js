import { LightningElement, track, api,wire } from 'lwc';
import PlusIC from '@salesforce/resourceUrl/PlusIconss';
import UpIcons from '@salesforce/resourceUrl/UpIconforBorrower';
import getLoanDetails from '@salesforce/apex/LWC_AllLoansCtrl.getLoanDetails';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class careBorrowersPageDev2 extends LightningElement {
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
    @api contactid = '003AD00000Bs9xdYAB';
    @track currentloandetails;
    showMore = false;
     val1;
    val2;
    allLoansPage = window.location.href.substring(0, window.location.href.indexOf('/s')+3)+'careviewallloans';
    getUrlParamValue(url, key){
        return new URL(url).searchParams.get(key);
    }

    @wire(LWCSectionMetaData, { category: 'careborrowerspage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for Loan schedule');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Loan schedule") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Loan in val1:', this.val1);
            console.log('@@@ schedule in val2:', this.val2);

        } else if (error) {
            // Handle error
        }
    }

    connectedCallback() {
        var bUrl = window.location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.borrowerUrl = bUrl+'/careborrowerspagedev2';
        //console.log('LoanId:');
        const tempId = 'loanId';//id
        this.loanId = atob(this.getUrlParamValue(window.location.href, tempId));
        //console.log( this.loanId);
        this.spin = true;
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
                        var v = parseInt(loanAmounts[i]);
                        if(v<=loanAmtLeftForFunding){
                            LoanAmounts.push( loanAmounts[i] ); //'$'+
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
                
               
                this.Funded__c = loan.Funded__c;
                var len = this.Funded__c!= undefined ? this.Funded__c : 0;
                if( this.Funded__c!= undefined && this.Funded__c > 85 ){
                    len-=1;
                    this.progressStyle = 'background-color: #2a871f; width:'+len+'%;';
                } else{
                    this.progressStyle = 'background-color: #ffd700;width:'+len+'%;';
                }
                var cMap = result.CurrencyType;
                if( loan.Repayment_Schedules__r!= undefined && loan.Repayment_Schedules__r.length>0 ){
                    this.showRepaySchedules = true;
                    var i = 1;
                    var repaySchedules = [];
                    for(var val of loan.Repayment_Schedules__r){
                       
                        var dueDate = val.Due_Date__c != undefined ? this.formatDate(val.Due_Date__c) : '-';
                        var expectedAmount = val.Amount_Due__c != undefined ? val.Amount_Due__c : '-';
                        if( cMap!=undefined && expectedAmount!='-' ){
                            var cAmt = cMap[val.CurrencyIsoCode]!=undefined ? cMap[val.CurrencyIsoCode] : 1;
                            expectedAmount = expectedAmount/cAmt;
                            expectedAmount = expectedAmount.toFixed(2);
                        }
                        var repayDate = val.Repayment_Date__c != undefined ? this.formatDate(val.Repayment_Date__c) : '-';
                        var obj = {'dueDate':dueDate, 'expectedAmount':expectedAmount, 'repayDate':repayDate};
                        obj.classes = i%2==0 ? 'slds-grid tableTitleContentSecond' : 'slds-grid tableTitleContent';
                        repaySchedules.push( obj );
                        i++;
                    }
                    this.repaymentSchedules = repaySchedules;
                    console.log('this.repaymentSchedules-- ',this.repaymentSchedules)
                    if( this.repaymentSchedules!=undefined && this.repaymentSchedules.length>7 ){
                        this.showMore = true;
                        this.repaymentSchedules = this.repaymentSchedules.slice(0,7);
                    }
                }
                if( loan.Transactions__r!= undefined && loan.Transactions__r.length>0 ){
                    var trans = [];
                    for(var val of loan.Transactions__r){
                        if( val.Lender__r != undefined && val.Lender__r.Name != undefined ){
                            var pPic = val.Lender__r!=undefined && val.Lender__r.Profile_Picture__c != undefined ? val.Lender__r.Profile_Picture__c:'';
                            //console.log('pPic:',pPic);
                            var obj = {'Name':val.Lender__r.Name, 'ProfilePic':pPic};
                            trans.push( obj );
                        } else{
                            continue;
                        }
                    }
                    this.contributors = trans;
                    if( trans.length > 0 )  this.showContributorsSection = true;
                    this.showContributors = trans.slice( 0, this.contributorsCount );
                    if( this.showContributors.length > 0 && this.showContributors.length<this.contributors.length ){
                        this.view14 = true;
                    }
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

formatDate(dateString) {
  const parsedDate = new Date(dateString);
  const day = parsedDate.getDate();
  const month = (parsedDate.getMonth() + 1).toString().padStart(2, '0');
  const year = parsedDate.getFullYear();
  
  return `${day}-${month}-${year}`;
}

// img3=img3;
@track screenWidth;
@track screenHeight;
@api slidesData;
// CarouselBan = CarBanner;
Plus = PlusIC;
slides=[];

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


  
}