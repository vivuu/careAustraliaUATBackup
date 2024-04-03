import { LightningElement,track, api } from 'lwc';
// import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
// import banner from '@salesforce/resourceUrl/UpdatedBanner';
// import banner1 from '@salesforce/resourceUrl/MobBanner';
//import mobileBanner from '@salesforce/resourceUrl/MobileBanner';
// import working from '@salesforce/resourceUrl/working';
import greenfield from '@salesforce/resourceUrl/greenfield';
// import testi1 from '@salesforce/resourceUrl/TestiBack';
// import Womenz from '@salesforce/resourceUrl/Women';
// import darklogo from '@salesforce/resourceUrl/DarkLogo';
// import SketchetikFillLight from '@salesforce/resourceUrl/SketchetikFillLight';
import LWCLogo from '@salesforce/resourceUrl/LWCLogoSvg';
import para2img from '@salesforce/resourceUrl/para2img';

import getCurrentUser from '@salesforce/apex/LWC_AllLoansCtrl.getCurrentUser';
import getContactInfo from '@salesforce/apex/LWC_AllLoansCtrl.getContactInfo';
import getCreditCardDetail from '@salesforce/apex/LWC_AllLoansCtrl.getCreditCardDetail';
import refundAndDonate from '@salesforce/apex/LWC_AllLoansCtrl.refundAndDonate';
import createRefundCase from '@salesforce/apex/LWC_AllLoansCtrl.createRefundCase';
import donateFromDashboard from '@salesforce/apex/LWC_AllLoansCtrl.donateFromDashboard';


export default class CareHomePage_header extends LightningElement {

    withdrawPayPal=false;
    withdrawPayPalPopup=false;
    withdrawCC=false;
    withdrawCCPopup=false;
    withdrawBoth=true;
    ThankYou=false;
    RequestReceived=false;
    UnabletoWithdraw=false;
    WithdrawImg=para2img;
    greenfield=greenfield;
    trData = {};
    LenderTopup = false;
    carecart=false;

    fromNavBar(event){
        if(event.detail == true){
            this.LenderTopup = false;
            this.carecart = false;
        }
    }

    truewithdrawPayPal(){
        this.withdrawPayPal = true;
        this.withdrawBoth = false;
        this.withdrawPayPalPopup=false;
        this.withdrawCC=false;
        this.withdrawCCPopup=false;
    }

    get searchBg(){
        return `background-image: url('${this.greenfield}');background-size: cover; background-repeat: no-repeat;`;
    }
    get searchBg1(){
        return `background-image: url('${this.greenfield}');background-size: cover; background-repeat: no-repeat;overflow-y:scroll;padding-top:50px`;
    }

    OpenPaypalPopUp(){
       this.withdrawPayPalPopup = true;
    }

    OpenReceivedRequest(){
        this.RequestReceived = true;
    }

    OpenContactUsPage() {
        //console.log('From Sayan contact us!!');
        window.location.assign('carecontactus');
    }

    CloseReceivedRequest(){
        this.RequestReceived = false;
        //window.location.assign('careDashboard');
        //window.location.replace('https://careaustralia--centqa.sandbox.my.site.com/LendwithCare/s/careDashboard');
        window.location.assign('carecontactus');
    }

    CloseThankYou(){
        //this.withdrawCCPopup = false;
        //this.ThankYou = false;

        this.amountToWithdraw = '';
        this.amountToDonate = '';
         window.location.assign('careDashboard');
    }

    CloseWithdrawCCpopUp(){
        this.withdrawCCPopup = false;
    }

    ClosewithdrawPayPalPopup(){
        this.withdrawPayPalPopup = false;
    }

    BacktoWithdrawPaypalPopUp(){
        this.withdrawPayPalPopup = false;
        this.withdrawPayPal = true;
        this.withdrawBoth = false;
        this.withdrawCC=false;
        this.withdrawCCPopup=false;
    }

    BacktoWithdrawCCpage() {
        this.withdrawPayPalPopup = false;
        this.withdrawPayPal = false;
        this.withdrawBoth = false;
        this.withdrawCC=true;
        this.withdrawCCPopup=false;
    }

    OpenThankYou(){
        this.isLoading = true;
        const request = {
            contactId:this.contactid, 
            refundAmount:this.getFloatAmount(this.amountToWithdraw), 
            donateAmount: this.getFloatAmount(this.amountToDonate),
            cardNumber: this.maskedCardNumber
        };
        refundAndDonate(request)
        .then((result) => {
            if(result)
            {
                this.RequestReceived=true;
            }
            else
            {
                this.ThankYou = true;
                this.lenderBalance = this.lenderBalance - (this.getFloatAmount(this.amountToWithdraw) + this.getFloatAmount(this.amountToDonate));
            }
            
            console.log('success in refundAndDonate');
        }).catch((error) => {
            console.log('error in refundAndDonate -> ', error);
        }).finally(() => {
            this.isLoading = false;
        });
    }

    truewithdrawCC(){
        this.withdrawPayPal = false;
        this.withdrawBoth = false;
        this.withdrawPayPalPopup=false;
        this.withdrawCC=true;
        this.withdrawCCPopup=false;
    }

    OpenWithdrawCCPopUp(){
        this.resetAmountValidity();
        console.log('Withdraw CC popup');
        let totalAmount = this.getFloatAmount(this.amountToWithdraw);
        
        if(this.includeDonation) {
            totalAmount = totalAmount + this.getFloatAmount(this.amountToDonate);
        }
        
        if(totalAmount === 0 || totalAmount > this.lenderBalance) {
            this.checkWithdrawAmountValidity = true;
            if(this.includeDonation) {
                this.checkDonationAmountValidity = true;
                
            }
        } else {
            const withDrawAmount = this.getFloatAmount(this.amountToWithdraw);
            if(withDrawAmount > 0) {
                this.isLoading = true;
                getCreditCardDetail({contactId: this.contactid, amount: withDrawAmount})
                .then((result) => {
                   if(result===null||result===undefined||withDrawAmount>100)
                   {
                        if(withDrawAmount!=null&&withDrawAmount>=0)
                        {
                            createRefundCase({contactId: this.contactid, refundAmount: withDrawAmount})
                        .then((result) => {
                                console.log('Got result-->',withDrawAmount);
                                if(this.includeDonation&&this.getFloatAmount(this.amountToDonate)>0)
                                {
                                    this.trData['Lender__c'] = this.contactid;
                                    this.trData['Amount__c'] = this.getFloatAmount(this.amountToDonate);
                                    this.trData['Type__c'] = 'Donation';
                                    donateFromDashboard({ rec: this.trData })
                                    .then(result => {
                                        console.log('result successfull from donation record ', JSON.stringify(result))
                    
                   // this.gotoThankYou();
                   // this.isLoading = false;
                                    })
                                    .catch(error => {
                  //  this.isLoading = false;
                                    console.log('error from donation record ', JSON.stringify(error))
                            })
                             }
                                this.RequestReceived=true;
                        })
                        .catch((error) => {
                        console.log('error in createRefundCase from get credit card', error);
                        })
                        }
                        
                  }
                   else
                   {
                       this.maskedCardNumber = result;
                       const numberDetails = result.split('*');
                       this.cardNumber = numberDetails[numberDetails.length - 1];
                       console.log('Finding error->'+withDrawAmount);
                       createRefundCase({contactId: this.contactid, refundAmount: withDrawAmount})
                        .then((result) => {
                                console.log('Got result-->',withDrawAmount);
                                if(this.includeDonation&&this.getFloatAmount(this.amountToDonate)>0)
                                {
                                    this.trData['Lender__c'] = this.contactid;
                                    this.trData['Amount__c'] = this.getFloatAmount(this.amountToDonate);
                                    this.trData['Type__c'] = 'Donation';
                                    donateFromDashboard({ rec: this.trData })
                                    .then(result => {
                                        console.log('result successfull from donation record ', JSON.stringify(result))
                    
                   // this.gotoThankYou();
                   // this.isLoading = false;
                                    })
                                    .catch(error => {
                  //  this.isLoading = false;
                                    console.log('error from donation record ', JSON.stringify(error))
                            })
                             }
                                this.RequestReceived=true;
                        })
                        .catch((error) => {
                        console.log('error in createRefundCase from others', error);
                        })
                       //this.withdrawCCPopup = true;
                  }
                    
                }).catch((error) => {
                    console.log('error in getCreditCardDetail', error);
                }).finally(() => {
                    this.isLoading = false;
                });
            } else {
                //this.withdrawCCPopup = true;
            }
        }
    }

    LenwithCareLogo = LWCLogo;

    get checkBoxOption() {
        return [
            { label: 'Tick here to apply donation amount.', value: 'option1' },
            
        ];
    }
     get comboboxOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
            
        ];
    }

    handleGoToDashboard() {
        window.location.assign('caredashboard');
    }


    @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;
    @api slidesData;

    contactid;
    lenderBalance = 0;

    amountToWithdraw = '';
    amountToDonate = '';

    checkWithdrawAmountValidity;
    checkDonationAmountValidity;

    includeDonation = true;

    cardNumber;
    maskedCardNumber;

    isLoading = false;

    connectedCallback() {
        this.isLoading = true;
        getCurrentUser()
        .then(result => {
            this.contactid = result.Contact.Id;
            getContactInfo({contactId: this.contactid})
            .then((data) => {
                //this.lenderBalance = data.contactRecord.Lender_Balance__c;
                this.lenderBalance=Math.round((data.contactRecord.Lender_Balance__c + Number.EPSILON) * 100) / 100;
                console.log('From connected callback-->'+this.lenderBalance);
            }).catch((error) => {
                console.log('error ', JSON.stringify(error))
            }).finally(() => {
                this.isLoading = false;
            });
        })
        .catch(error => {
            console.log('error ', JSON.stringify(error))
        })
    }


    handleWithdrawAmountChange(event) {
        this.resetAmountValidity();

        this.amountToWithdraw = event.target.value;
        console.log('this.amountToWithdraw -> ' + this.amountToWithdraw);
    }

    handleDonationAmountChange(event) {
        this.resetAmountValidity();

        this.amountToDonate = event.target.value;
        console.log('this.amountToDonate -> ' + this.amountToDonate);
    }

    handleIncludeDonationChange() {
        this.includeDonation = !this.includeDonation;
        this.resetAmountValidity();
    }

    resetAmountValidity() {
        this.checkWithdrawAmountValidity = false;
        this.checkDonationAmountValidity = false;
    }

    getFloatAmount(value) {
        return parseFloat(value ? value : 0);
    }

    get wholeLenderBalance() {
        console.log('Lender balance-->'+this.lenderBalance+'Lender balance to string'+this.lenderBalance.toString());
        return this.lenderBalance && this.lenderBalance.toString() ? this.lenderBalance.toString().split('.')[0] : '00';
    }

    get precisionLenderBalance() {
        return this.lenderBalance && this.lenderBalance.toString() ? this.lenderBalance.toString().split('.').length == 2 ? this.lenderBalance.toString().split('.')[1] : '00' : '00';
    }

    get amountWithdrawalPlaceholder() {
        return `eg: ${this.wholeLenderBalance}.${this.precisionLenderBalance}`;
    }

    get reviewMessage() {
        if(this.amountToWithdraw && this.amountToDonate) {
            return `You have requested to withdraw $${this.amountToWithdraw} and donate $${this.amountToDonate}. Thank you.`
        } else {
            if(this.amountToWithdraw) {
                return `You have requested to withdraw $${this.amountToWithdraw}. Thank you.`
            } else {
                return `You have requested to donate $${this.amountToDonate}. Thank you.`
            }
        }
    }

    /*@track carouselItems = [
        {
            id: 1,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 1',
            description: 'This is the first slide of the carousel.'
        },
        {
            id: 2,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 2',
            description: 'This is the second slide of the carousel.'
        },
        {
            id: 3,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 3',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 4,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 4',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 5,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 5',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 6,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 6',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 7,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 7',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 8,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 8',
            description: 'This is the third slide of the carousel.'
        }
    ];

    slides=[
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Parichat Borrower'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Gowsic Nagarajan'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Partha Sarathy'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Vivek Kulangathu'
        },
        
    ]

    profilepic = LendWithCareImages+'/client1.png';
    careLogo=LendWithCareImages+'/care.png';
    careLogos=LendWithCareImages+'/country.png';
    lendLogo=LendWithCareImages+'/logo.png';
    lenddarklogo = darklogo;

    Working = working;
    Greenfield = greenfield;
    GWomen = Womenz;
   
    
    lendAgainImg = LendWithCareImages+'/lendagain.png';
    replyImg = LendWithCareImages+'/reply.png';
    growImg = LendWithCareImages+'/grow.png';
    yourLendImg = LendWithCareImages+'/yourlend.png';
    clientImg = LendWithCareImages+'/client1.png';
    checkcircles = LendWithCareImages+'/CheckCircle.png';
    testimonialBackground = LendWithCareImages+'/testimonialbg.png';
    banner = banner; //LendWithCareImages+'/banner.jpeg';
    banner1 =banner1  // LendWithCareImages+'/mobile-banner.png'; //mobileBanner;
    testi = LendWithCareImages+'/testimonialbg.jpeg';
    testi1 = testi1;

    @track currentSlideIndex = 0;
    @track visibleSlides = 4;

    withdrawPayPal=true;

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
        }
    }

    nextSlide() {
        if (this.currentSlideIndex < this.carouselItems.length - this.visibleSlides) {
            this.currentSlideIndex++;
        }
    }

    handleDotClick(event) {
        const index = event.target.dataset.index;
        this.currentSlideIndex = parseInt(index);
    }

    openLoginPage() {
        this.loginPage = true;
    }

    openMenu() {
        this.isMenuOpen = true;
    }

    closeMenu() {
        this.isMenuOpen = false;
    }

    SearchMenuOpen(){
        this.isSearchMenuOpen = true;
    }

    closeSearchMenu(){
        this.isSearchMenuOpen = false;
    }

    toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }

      toggleDropdownAbout() {
    this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
  }

    get testimoni(){
        
        if(this.screenWidth <= 414 && this.screenHeight <= 915){
        return `background-image: url('${this.testi1}');background-size: cover; background-repeat: no-repeat;Height:725px;`;
        }
        else{
            return `background-image: url('${this.testi}');background-size: cover; background-repeat: no-repeat;Height:546px;`;
        }

        
    }

   get backgroundImage() {

    this.getScreenSize();
    
    if(this.screenWidth <= 414 && this.screenHeight <= 915){
        return `background-image: url('${this.banner1}');background-size: cover; background-repeat: no-repeat;`;
    }
    else{
        return `background-image: url('${this.banner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
    }
    
  }  
  connectedCallback() {
    this.getScreenSize();
    window.addEventListener('resize', this.getScreenSize.bind(this));
  }
  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }


    
    

    handleSlide(event) {
    
    const relatedTarget = event.detail.relatedTarget;
    const idx = Array.from(relatedTarget.parentNode.children).indexOf(relatedTarget);
    const itemsPerSlide = 5;
    const totalItems = this.template.querySelectorAll('.carousel-item').length;

    if (idx >= totalItems - (itemsPerSlide - 1)) {
        const it = itemsPerSlide - (totalItems - idx);
        for (let i = 0; i < it; i++) {
            // append slides to end
            if (event.detail.direction === 'left') {
                this.template.querySelectorAll('.carousel-item')[i].parentNode.appendChild(
                    this.template.querySelectorAll('.carousel-item')[i]
                );
            } else {
                this.template.querySelector('.carousel-inner').appendChild(
                    this.template.querySelectorAll('.carousel-item')[0]
                );
            }
        }
    }
}*/
}