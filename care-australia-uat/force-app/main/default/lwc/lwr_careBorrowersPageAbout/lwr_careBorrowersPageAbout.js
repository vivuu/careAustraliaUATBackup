import { LightningElement, track, api } from 'lwc';
import PlusIC from '@salesforce/resourceUrl/PlusIconss';
import UpIcons from '@salesforce/resourceUrl/UpIconforBorrower';
import getLoanDetails from '@salesforce/apex/LWC_AllLoansCtrl.getLoanDetails';
import basePath from '@salesforce/community/basePath';
export default class Lwr_careBorrowersPageAbout extends LightningElement {
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

    // allLoansPage = window.location.href.substring(0, window.location.href.indexOf('/s')+3)+'careviewallloans';
    allLoansPage = basePath+'/'+'careviewallloans';
    getUrlParamValue(url, key){
        return new URL(url).searchParams.get(key);
    }
    connectedCallback() {
        // var bUrl = window.location.href;
        var bUrl = location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.borrowerUrl = bUrl+'/careborrowerspagedev2';
        //console.log('LoanId:');
        const tempId = 'loanId';//id
        // this.loanId = atob(this.getUrlParamValue(window.location.href, tempId));
        this.loanId = atob(this.getUrlParamValue(location.href, tempId));
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
                var names = [];
                for( var val of loanImages ){
                    if( val.Name.includes('_cover_round') ){
                        this.coverImage = val.ContentDownloadUrl;
                    } else if( !val.Name.includes('_cover') && !names.includes(val.Name) ){
                        console.log('NNN:',val.Name);
                        carouselImages.push( {'image':val.ContentDownloadUrl} );
                    }
                    names.push(val.Name);
                }
                this.slides = carouselImages;
                this.carouselImages = carouselImages;
                this.Loan_Title__c=loan.Loan_Title__c;
                var country = loan.Borrower__r !=undefined ? loan.Borrower__r.City__c != undefined ?loan.Borrower__r.City__c +'-'+loan.Borrower__r.Country__c:loan.Borrower__r.Country__c : '';
                this.loc= country;
                // this.borrowerName = loan.Borrower__r!=undefined && loan.Borrower__r.Name!=undefined? loan.Borrower__r.Name:'';
                this.borrowerName = loan.Borrower__r!=undefined? loan.Borrower__r.Published_Name__c!=undefined?loan.Borrower__r.Published_Name__c:loan.Borrower__r.FirstName!=undefined?loan.Borrower__r.FirstName:'' : '';
                var bDes = loan.Borrower__r!=undefined && loan.Borrower__r.Description!=undefined? loan.Borrower__r.Description:'';
                if( bDes!=undefined ){
                    this.borrowerDescription = bDes.split('\n');
                }
                this.Loan_Type__c=loan.Loan_Type__c;
                this.Loan_Description__c=loan.Loan_Description__c;
                this.Amount_Funded__c=loan.Amount_Funded__c!=undefined?'$'+loan.Amount_Funded__c+' Lent' : '';
                this.Loan_Term_Months__c=loan.Loan_Term_Months__c!=undefined?loan.Loan_Term_Months__c+' months':'';
                this.Loan_Schedule__c=loan.Loan_Schedule__c;
                this.Published_Amount_AUD__c=loan.Published_Amount_AUD__c!=undefined?'$'+parseInt(loan.Published_Amount_AUD__c).toFixed(2)+' Goal' : '';
                if( loan.Stage__c=='Active' || loan.Amount_Left_Before_Fully_Funded__c==0 ){
                    this.showCart = false;
                }
                this.Funded__c = loan.Funded__c;
                var len = this.Funded__c!= undefined ? this.Funded__c : 0;
                if( this.Funded__c!= undefined && this.Funded__c > 85 ){
                    len-=1;
                    this.progressStyle = 'background-color: #2a871f; width:'+len+'%;';
                } else{
                    this.progressStyle = 'background-color: #ffd700;width:'+len+'%;';
                }
                if( loan.Repayment_Schedules__r!= undefined && loan.Repayment_Schedules__r.length>0 ){
                    this.showRepaySchedules = true;
                    var i = 1;
                    var repaySchedules = [];
                    for(var val of loan.Repayment_Schedules__r){
                        var dueDate = val.Due_Date__c != undefined ? val.Due_Date__c : '-';
                        var expectedAmount = val.Amount_Due__c != undefined ? val.Amount_Due__c : '-';
                        var repayDate = val.Repayment_Date__c != undefined ? val.Repayment_Date__c : '-';
                        var obj = {'dueDate':dueDate, 'expectedAmount':expectedAmount, 'repayDate':repayDate};
                        obj.classes = i%2==0 ? 'slds-grid tableTitleContentSecond' : 'slds-grid tableTitleContent';
                        repaySchedules.push( obj );
                        i++;
                    }
                    this.repaymentSchedules = repaySchedules;
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
           console.log('INAGES:',this.carouselImages, this.slides);
            setTimeout(() => {
                this.spin = false;
            }, 3000);
        }).catch( err=>{
            console.log('Error : ',err);
            this.spin = false;
        } )
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
    // const currentPageUrl = window.location.href;
    const currentPageUrl = location.href;
    // var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s')+3);
    var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s'));
    // window.location.href = currentPageUrl2+'careallloanschedules?loanId='+btoa(this.loanId);
    location.href = basePath+'/'+'careallloanschedules?loanId='+btoa(this.loanId);
  }
}