import { LightningElement, track, api, wire } from 'lwc';
import DashboardPersonAvatars from '@salesforce/resourceUrl/DashboardPersonAvatar';
import greenfield from '@salesforce/resourceUrl/greenfield';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import ChartImg from '@salesforce/resourceUrl/chartimage';
import CarBanner from '@salesforce/resourceUrl/CarBanner';
import shoppingicon from '@salesforce/resourceUrl/ShoppingCarIcon';
//import getCommunityUser from '@salesforce/apex/LWC_AllLoansCtrl.getCommunityUser';
import getAllLoansDev from '@salesforce/apex/LWC_AllLoansCtrl.getAllLoansDev';
import getYourTransactionDetails from '@salesforce/apex/LWC_AllLoansCtrl.getYourTransactionDetails';
import getContactInfo from '@salesforce/apex/LWC_AllLoansCtrl.getContactInfo';
import putContactInfo from '@salesforce/apex/LWC_AllLoansCtrl.putContactInfo';
import getCurrentUser from '@salesforce/apex/LWC_AllLoansCtrl.getCurrentUser';
import basePath from '@salesforce/community/basePath';

//import { NavigationMixin } from 'lightning/navigation';
//import { refreshApex } from '@salesforce/apex';

const columns = [
    { label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date', initialWidth: 150 },
    { label: 'Type', fieldName: 'Type__c', initialWidth: 100 },
    { label: 'Amount', fieldName: 'Amount__c', initialWidth: 100 },
    {
        label: 'Download', type: 'button-icon',
        initialWidth: 50,
        typeAttributes: {
            iconName: 'utility:download',
            name: 'download',
            title: 'Download',
            disabled: { fieldName: 'disableDownloadButton' },
            variant: 'bare',
            alternativeText: 'Download'
        },
        cellAttributes: {
            class: { fieldName: 'downloadButtonClass' }
        }
    }
];

export default class Lwr_carouselcmp_Homepage extends LightningElement {

    @api contactid;// = '003AD00000Bs9xdYAB'; //gowsic contact id
    dasAvatarpic = DashboardPersonAvatars;
    avatarpic = greenfield;
    AvatarImg;
    Champion = false;
    chartcolors = ChartImg;
    CarouselBan = CarBanner;
    shopicon = shoppingicon;
    PersonalDetails = false;
    DonatePopup = false;
    thankyouPopup = false;
    withdrawPopup = false;
    CloseThankyouPopup = false;
    showalltransactionspopup = false;

    @track UserName;
    @track AmountValues;
    @track TotalLoans;
    @track JobsCreated;
    @track Totalamountlent;
    @track Peoplehelped;

    @track Repaidbyborrower;
    @track Donated;
    @track Addedtoyouraccount;
    @track Withdrawnfromyouraccount;


    progressBarInnerElement;
    stage = 'All';
    @track carouselItems = [];
    @track loansdata = [];
    @track isLoading = false;
    columns = columns;
    transactions = [];
    showAll = false;
    type = 'All';
    @track isSelected = false;
    @track showButton = true;
    @track relendCheckbox = false;
    @track FirstName;
    @track LastName;
    firstFourItems = [];
    displayPreviousButtom=false;
    displayNextButtom=true;
    activeIndex = 0; // Initialize with the first item as active

    
    refreshData() {
        refreshApex(this.wiredTransactionData);
    }
    get getButtonClasses() {
        return 'PillsButton ' + (this.isSelected ? 'selected' : '');
    }

    handleButtonClick(event) {
        this.type = event.target.dataset.type;
        this.isLoading = event.target.dataset.type === 'All' ? false : true;
        this.refreshData();
        this.isSelected = !this.isSelected;
        //console.log('@@@@@dataset' + event.target.dataset.type);
    }
    handleFirstName(event) {
        this.FirstName = event.target.value;
    }

    handleLastName(event) {
        this.LastName = event.target.value;
    }
    // //'003AD00000Bs9xdYAB','Anirudh','P Test'
    // @wire(putContactInfo, { contactId : '003AD00000Bs9xdYAB',FirstName : 'Anirudh',LastName :'Test' })
    // wiredContactData({ error, data }) {
    //     if (data) {
    //         console.log('@@@ASDF@@@'+JSON.stringify(data)); 

    //     }else if (error) {
    //         console.error('Error loading data:', error);
    //     }
    // }


    @wire(getContactInfo, { contactId: '$contactid' })
    wiredContactData({ error, data }) {
        if (data) {
            //console.log('data@@@' + JSON.stringify(data.mapOfTypeAndAmount['Loan']+data.mapOfTypeAndAmount['Donation']));
            this.AvatarImg = data.contactRecord.Profile_Picture__c;
            //console.log(this.AvatarImg);
            this.UserName = data.contactRecord.Name;
            this.AmountValues = data.contactRecord.Lender_Balance__c;
            this.TotalLoans = data.contactRecord.Total_Loans__c != null ? data.contactRecord : '00';
            this.Champion = data.contactRecord.Champion__c;
            this.relendCheckbox = data.contactRecord.Auto_Relend__c;
            this.JobsCreated = data.contactRecord.sumOfJobsCreated != null ? data.contactRecord.sumOfJobsCreated : '00';
            this.Totalamountlent = data.totalTransactionsAmount;
            this.Peoplehelped = data.contactRecord.Total_People_Helped__c != null ? data.contactRecord.Total_People_Helped__c : '00';
            this.Repaidbyborrower = data.mapOfTypeAndAmount['Repayment'] != null ? data.mapOfTypeAndAmount['Repayment'] : '00';
            this.Donated = data.mapOfTypeAndAmount['Donation'] != null ? data.mapOfTypeAndAmount['Donation'] : '00';
            this.Addedtoyouraccount = data.mapOfTypeAndAmount['Topup'] != null ? data.mapOfTypeAndAmount['Topup'] : '00';
            this.Withdrawnfromyouraccount = data.mapOfTypeAndAmount['Withdrawal'] != null ? data.mapOfTypeAndAmount['Withdrawal'] : '00';

        } else if (error) {
            console.error('Error loading data:', error);
        }
    }

    @wire(getYourTransactionDetails, { type: '$type', contactId: '$contactid', showAll: '$showAll' })
    wiredTransactionData({ error, data }) {
        this.isLoading = false;

        // let formattedDate = new Date(data[0].Completed_Date__c).toLocaleDateString("en-GB");
        // console.log(formattedDate);

        if (data) {
            this.transactions = data.map((transaction) => ({
                ...transaction,
                disableDownloadButton: transaction.Type__c !== 'Donation',
                downloadButtonClass: transaction.Type__c === 'Donation' ? 'slds-show' : 'slds-hide',
            }));
        } else if (error) {
            console.error('Error loading data:', error);
        }
    }

    getRowClass(index) {
        return index % 2 === 0 ? 'even-row' : 'odd-row';
    }

   /* @wire(getLoansByStage, { stage: '$stage', contactId: '$contactid' })
    wiredLoans({ error, data }) {
        this.isLoading = false; 
        if (data) {
            this.loansdata = null;
            getLoansForCarousel = data;
            this.error = undefined;
            console.log('@@@@loansdata', JSON.stringify(this.loansdata));
            this.getcorousal();
        } else if (error) {
            this.error = error;
            this.loansdata = [];
        }
    }*/
    noLoans = false;
    contentDis;
    @api getLoansForCarousel( fValue ){
        console.log('llContactId:',this.contactid);
        getAllLoansDev({'contactId':this.contactid, 'filter':fValue})
        .then(result => {
            console.log('TRRANS:',result, this.contactid);
            if( result == undefined || (result != undefined && result.length <=0) ){
                this.noLoans = true;
            } else{
                this.noLoans = false;
                this.loansdata = result.Loan;
                this.contentDis = result.ContentDistribution;
                console.log('LDATa:',this.loansdata);
                this.getcorousal();
            }
            //console.log('Result All Loans-->'+ JSON.stringify(this.loansdata));
        })
        .catch(error => {
            this.noLoans = true;
            console.log(error);
        });
    }

    formatCompletedDate(dateString) {
        const date = new Date(dateString);
        const day = date.getDate().toString().padStart(2, '0');
        const month = (date.getMonth() + 1).toString().padStart(2, '0'); // Months are 0-based
        const year = date.getFullYear();
        return `${day}-${month}-${year}`;
    }
    currentUser(){
        getCurrentUser()
        .then(result => {
            console.log('current user -dashboard ', JSON.stringify(result))
            this.contactid = result.Contact.Id;
            console.log('this.contactid--> getCurrentUser() ', this.contactid);
            /* if( this.contactid!=undefined ){
                this.getContactFields();
            } */
        })
        .catch(error => {
            console.log('error ', JSON.stringify(error))
        })
    }
    borrowerUrl;
    connectedCallback() {
        // var bUrl = window.location.href;
        var bUrl = location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.borrowerUrl = bUrl+'/careborrowers';
        setTimeout(() => {
            this.getLoansForCarousel('All');
            
        }, 6000);
        
        // getCommunityUser()
        //     .then(result => {
        //         console.log('Result: ', result);
        //     })
        //     .catch(error => {
        //         console.error('Error: ', error);
        //     });

        // let checkbox = this.template.querySelector('[data-id="relendCheckbox"]');
        // checkbox.checked = true;
    }

    // async fetchAndSetImage(url) {
    //     const dataUrl = await fetchAndConvertImage(url);
    //     if (dataUrl) {
    //         this.AvatarImg = dataUrl;
    //     }
    // }

    confirmChanges(event){
        console.log('ENTER IN CONFIRM CHANGES'+this.contactid+' '+JSON.stringify(this.FirstName)+' '+JSON.stringify(this.LastName) );
        putContactInfo({ contactId: this.contactid, FirstName: this.FirstName, LastName: this.LastName }) //LWC_AllLoansCtrl.putContactInfo('003AD00000Bs9xdYAB','Anirudh','Test')
            .then(updatedContact => {
                //console.log('ENTER IN CALLING APEX');
                // Success handling, if needed
                //console.log('Contact updated:', updatedContact);
                // Refresh the page to reflect the updated contact details
                this.PersonalDetails = false;
                // Call refreshApex if you need to refresh other data fetched using @wire
                location.reload();
            })
            .catch(error => {
                // Error handling, if needed
                console.error('Error updating contact:', error);
            });
    }

    updatePersonalDetails() {
        this.PersonalDetails = true;
    }
    ClosePersonalDetails() {
        this.PersonalDetails = false;
    }
    openWithdrawPopup() {
        this.withdrawPopup = true;
    }
    closePopup() {
        this.withdrawPopup = false;
    }
    handleViewTransactionsClick() {
        // const baseUrl = 'https://careaustralia--mfadev.sandbox.my.site.com/LendwithCare/s/';
        
        const urlWithParameters = basePath + '/'+'caredasboardtransactions?Id=' + btoa(this.contactid);
        

        // window.location.href = urlWithParameters;
        location.href = urlWithParameters;
    }
    navigateTocarebecomechangechampionURL() {
        // window.location.href = 'https://careaustralia--mfadev.sandbox.my.site.com/LendwithCare/s/carebecomechangechampion';
        location.href = basePath+'/'+'carebecomechangechampion';
    }

    navigateToBorrowerupdates() {
        // window.location.href = 'https://careaustralia--mfadev.sandbox.my.site.com/LendwithCare/s/careborrowerspage';
        location.href = basePath+'/'+'careborrowers';
    }

    handleDownloadStatementClick() {
        // Logic to handle the "Download statement" button click
        // This is where you can implement what happens when the button is clicked
    }


    getcorousal() {
        this.carouselItems = [];
        this.loansdata.forEach(loan => {
            var cd = this.contentDis!=undefined ? this.contentDis[loan.Id]:undefined;
            var imgBgStyle;
            if( cd != undefined ){
                var imgUrl = cd[0].ContentDownloadUrl;
                imgBgStyle = `background-image: url('${imgUrl}');background-size: cover; background-repeat: no-repeat;`;
            }
            var country = loan.Borrower__r !=undefined ? loan.Borrower__r.City__c != undefined ?loan.Borrower__r.City__c +'-'+loan.Borrower__r.Country__c:loan.Borrower__r.Country__c : '';
            let carouselItem = {
                id: loan.Id,
                readMoreLink:this.borrowerUrl + '?loanId='+btoa(loan.Id),
                getcarbackImage:imgBgStyle,
                imageUrl: LendWithCareImages + '/client1.png',
                title: loan.Loan_Title__c!=undefined && loan.Loan_Title__c.length>50 ?loan.Loan_Title__c.substring(0,51):loan.Loan_Title__c,
                location: country,
                description: loan.Loan_Purpose__c != undefined && loan.Loan_Purpose__c !='' ? loan.Loan_Purpose__c.length > 80 ? loan.Loan_Purpose__c.substring(0, 80) + "..." : loan.Loan_Purpose__c: loan.Loan_Purpose__c!=undefined?loan.Loan_Purpose__c.length > 80 ? loan.Loan_Purpose__c.substring(0, 80) + "..." : loan.Loan_Purpose__c : '',
                Lent: loan.Amount_Funded__c!=undefined?loan.Amount_Funded__c:0,
                Goal: loan.Funded__c == 100 ? 'Goal Reached!' : 0,
                Button: loan.Loan_Type__c,
                //widthValue: 'width:' + (loan.Loan__r?.Funded__c != null ? loan.Funded__c : '0') + '%;',
                progress: loan.Funded__c,
                Funded__c: loan.Amount_Funded__c?loan.Amount_Funded__c:0,
                Published_Amount_AUD__c: parseFloat(loan.Published_Amount_AUD__c).toFixed(2),
                fullyFunded: Math.floor(loan.Amount_Funded__c) >= Math.floor(loan.Published_Amount_AUD__c),
            };
            this.carouselItems.push(carouselItem);
        });
        this.firstFourItems = this.carouselItems.slice(0, 4);
        //console.log('4 Car Items-->'+this.firstFourItems.length);
        //console.log('Total Car Items-->'+ JSON.stringify(this.carouselItems));
    }
    rendered = false;
    renderedCallback(){
        if( !this.rendered ){
            this.currentUser();
            this.rendered = true;
        }
        const progressBarElements = this.template.querySelectorAll('.progressBarInner');
    //console.log('ele2');

    // Fetch your JSON data here (e.g., using fetch, import, or received from parent component)
    if(progressBarElements){
        // Loop through each progress bar element and set its styles based on JSON data
        progressBarElements.forEach((progressBar) => {
        const progressValue = (progressBar.dataset.value >=98)?98:progressBar.dataset.value;//progressBar.dataset.value - 2:progressBar.dataset.value;
        //console.log('progressValue - 2 ', progressValue)
        progressBar.style.width = progressValue + "%";
        if (progressValue < 85) {
            progressBar.style.backgroundColor = "#FEBE10";
        } else {
            progressBar.style.backgroundColor = "#5C8F39";
        }
        });
    }
    }

    @api handleChange(event) {
        console.log('Selected Value: from child component ', event);
        this.carouselItems = [];
        this.stage = event.target.value;
        this.isLoading = true;
        console.log('Selected Value: from child component ', this.stage);
    }





    @track currentSlideIndex = 0;
    @track visibleSlides = 4;

    get getcarbackImage() {
        return `background-image: url('${this.CarouselBan}');background-size: cover; background-repeat: no-repeat;`;
    }

    get sliderStyles() {
        //console.log('currentSlideIndex-->'+this.currentSlideIndex);
        //console.log('visibleSlides-->'+this.visibleSlides);
        const translateXValue = this.currentSlideIndex * (100 / this.visibleSlides);
        //console.log('translateXValue-->'+translateXValue);
        return `transform: translateX(-${translateXValue}%);`;
    }

    get visibleCarouselItems() {
        return this.carouselItems.slice(this.currentSlideIndex, this.currentSlideIndex + this.visibleSlides);
    }

    previousSlide() {
        //console.log('currentSlideIndex Previous-->'+this.currentSlideIndex);
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
        //console.log('currentSlideIndex Next-->'+this.currentSlideIndex);
        if (this.currentSlideIndex < this.carouselItems.length - this.visibleSlides) {
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



}