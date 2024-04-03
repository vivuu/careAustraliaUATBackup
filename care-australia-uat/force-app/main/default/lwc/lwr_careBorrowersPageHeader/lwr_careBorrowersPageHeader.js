import { LightningElement, track, api } from 'lwc';
import UpIcons from '@salesforce/resourceUrl/UpIconforBorrower';
import getLoanDetails from '@salesforce/apex/LWC_AllLoansCtrl.getLoanDetails';
import basePath from '@salesforce/community/basePath';

export default class Lwr_careBorrowersPageHeader extends LightningElement {
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
    // @api contactid = '003AD00000Bs9xdYAB';
    @track currentloandetails;

    // allLoansPage = window.location.href.substring(0, window.location.href.indexOf('/s')+3)+'careviewallloans';
    allLoansPage = basePath+'/'+'careviewallloans';
    getUrlParamValue(url, key){
        return new URL(url).searchParams.get(key);
    }
    handleAddLoan(event) {	
        const loanData = event.detail; // Get the loan data from the Add Loan child component	
        	
        const childComponent = this.template.querySelector('c-lwr_care-nav-bar');	
            //console.log('before if (childComponent)')	
            if (childComponent) {	
                //console.log('if (childComponent)')	
                // Call the startTimer() method in the child component	
                //childComponent.loanidfromparent = this.flId;	
                childComponent.loanidfromparent = loanData; 	
                console.log('from loan to navbar cart ', JSON.stringify(childComponent.loanidfromparent))	
            }	
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
        console.log('this.loanId -- ', this.loanId);
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
                console.log('loan.Amount_Funded__c--> ',loan.Amount_Funded__c)
                const childComponent = this.template.querySelector('c-lwr_add-loan');	
                if (childComponent) {	
                    childComponent.currentloandetails = loan;	
                }
                console.log('LOANOO:',loan);
                var loanAmtLeftForFunding = result.Loan[0].Amount_Left_Before_Fully_Funded__c != undefined?result.Loan[0].Amount_Left_Before_Fully_Funded__c : result.Loan[0].Published_Amount_AUD__c;
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
                    if( !LoanAmounts.includes(0) ){
                        LoanAmounts.unshift(0);    
                    }
                }
                console.log('LAMT:',LoanAmounts);
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
                this.slides = carouselImages;
                this.carouselImages = carouselImages;
                this.Loan_Title__c=loan.Loan_Title__c;
                var country = loan.Borrower__r !=undefined ? loan.Borrower__r.City__c != undefined ?loan.Borrower__r.City__c +'-'+loan.Borrower__r.Country__c:loan.Borrower__r.Country__c : '';
                this.loc= country;
                this.borrowerName = loan.Borrower__r!=undefined && loan.Borrower__r.Name!=undefined? loan.Borrower__r.Name:'';
                var bDes = loan.Borrower__r!=undefined && loan.Borrower__r.Description!=undefined? loan.Borrower__r.Description:'';
                if( bDes!=undefined ){
                    this.borrowerDescription = bDes.split('\n');
                }
                this.Loan_Type__c=loan.Loan_Type__c;
                this.Loan_Description__c=loan.LWC_Loan_Description__c != undefined && loan.LWC_Loan_Description__c !='' ? loan.LWC_Loan_Description__c:loan.Loan_Description__c;
                
                this.Amount_Funded__c=loan.Amount_Funded__c!=undefined?parseFloat(loan.Amount_Funded__c).toFixed(2) : 0;
                
                
                this.Amount_Funded__c=parseFloat(Number(this.Amount_Funded__c) + Number(loan.Expected_Fund_From_Cart__c!=undefined?parseFloat(loan.Expected_Fund_From_Cart__c).toFixed(2) : 0)).toFixed(2);


                console.log('131-->',this.Amount_Funded__c, loan.Expected_Fund_From_Cart__c);
                this.Loan_Term_Months__c=loan.Loan_Term_Months__c!=undefined?loan.Loan_Term_Months__c+' months':'';
                this.Loan_Schedule__c=loan.Loan_Schedule__c;
                this.Published_Amount_AUD__c=loan.Published_Amount_AUD__c!=undefined?'$'+parseFloat(loan.Published_Amount_AUD__c).toFixed(2)+' Goal' : '';
                if( loan.Stage__c!='Fundraising' || loanAmtLeftForFunding==0 ){
                    this.showCart = false;
                }
                this.Funded__c = loan.Funded__c;
                var len = this.Funded__c!= undefined ? this.Funded__c : 0;
                var progressLength = (len >= 98.70) ? 99.00 : len;
                if( this.Funded__c!= undefined && this.Funded__c > 85 ){
                    len-=1;
                    this.progressStyle = 'background-color: #2a871f; width:'+progressLength+'%;';
                } else{
                    this.progressStyle = 'background-color: #ffd700;width:'+progressLength+'%;';
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
                
                    
            
            setTimeout(() => {
                this.spin = false;
            }, 3000);
        }}).catch( err=>{
            console.log('Error : ',err);
            this.spin = false;
        } )
    }

    handleProgressChange( event ){
        //this.Amount_Funded__c = event.detail.amtFunded;
        // this.Amount_Funded__c = this.Amount_Funded__c!=undefined?this.Amount_Funded__c:0;
        console.log('176-->',this.Amount_Funded__c);
        var len = event.detail.progress;
        var progressLength = (len >= 98.70) ? 99.00 : len;
        if( len > 85 ){
            len-=1;
            this.progressStyle = 'background-color: #2a871f; width:'+progressLength+'%;';
        } else{
            this.progressStyle = 'background-color: #ffd700;width:'+progressLength+'%;';
        }
    }
}