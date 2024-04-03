import { LightningElement, track,wire,api } from 'lwc';
/* import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import ladyWithGreen from '@salesforce/resourceUrl/ladyWithGreen';
import greenFieldSlope from '@salesforce/resourceUrl/greenFieldSlope';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent'; */
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';
/* import img5 from '@salesforce/resourceUrl/img5';
import img6 from '@salesforce/resourceUrl/img6';
import img3 from '@salesforce/resourceUrl/img3'; 
import OurImpactBanner from '@salesforce/resourceUrl/OurImpactBanner';
import OurImpactBanner1 from '@salesforce/resourceUrl/OurImpactMobileBan';*/
/* import LWCLogo from '@salesforce/resourceUrl/LWCLogoSvg';
import ChartImg from '@salesforce/resourceUrl/chartimage'; */
import basePath from '@salesforce/community/basePath';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import getImpactInfo from '@salesforce/apex/LWC_AllLoansCtrl.getImpactInfo';

export default class CareOurImpactYourImpact extends LightningElement {

    @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;

    desktopimage;
    imgUrl = basePath + '/sfsites/c';
    title1;
    title2;
    title3;
    title4;
    impactbody;
    empowerbody;
    approachbody;
    evidencebody;
    /* image1;
    image2; */

    @api contactid = null;
/*     LenwithCareLogo = LWCLogo;
    chartcolors = ChartImg;

    lendLogo = LendWithCareImages + '/logo.png';
    ladyWithGreen = ladyWithGreen;
    greenFieldSlope = greenFieldSlope;
    img3 = img3;
    img5 = img5;
    img6 = img6; */
    val1;
    val2;
    TotalLoans;
    Totalamountlent;
    JobsCreated;
    Peoplehelped;

    @wire(getImpactInfo)
    wiredContactData({ error, data }) {
        if (data) {
            this.carouselItemsImpact = [
                {
                    title: data.NumberOfLoans,
                    description: 'Number of loans.'
                },
                {
                    title: data.totalAmountLent!=undefined?'$'+Number(data.totalAmountLent).toFixed(2):'$0',
                    description: 'Total amount lent.'
                },
                {
                    title: data.JobsCreated,
                    description: 'Jobs created'
                },
                {
                    title: data.PeopleHelped,
                    description: 'People helped'
                },
        ];
        console.log('this.carouselItemsImpact ', this.carouselItemsImpact[0].title);
        this.TotalLoans = this.carouselItemsImpact[0].title;
        this.Totalamountlent = this.carouselItemsImpact[1].title;
        this.JobsCreated = this.carouselItemsImpact[2].title;
        this.Peoplehelped = this.carouselItemsImpact[3].title;
        } else if (error) {
            console.error('Error loading data:', error);
        }
    }
    @wire(LWCSectionMetaData, { category: 'ourimpactpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire ourimpactpage 3rd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Your Impact") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Your Impact in val1:', this.val1); 
            console.log('@@@in val2:', this.val2);

        } else if (error) {
            // Handle error
        }
    }

    @track carouselItemsImpact; /* = [
        {

            title: '17',
            description: 'Number of loans.'

        },
        {
            title: '$340',
            description: 'Total amount lent.'
        },
        {
            title: '17',
            description: 'Number of loans.'
        },
        {
            title: '$340',
            description: 'Total amount lent.'
        }
    ]; */

    @track currentSlideIndexImpact = 0;
    @track visibleSlidesImapct = 8;

    get sliderStylesImpact() {
        const translateXValue = this.currentSlideIndexImpact * (100 / this.visibleSlidesImapct);
        return `transform: translateX(-${translateXValue}%);`;
    }

    handleDotClickImpact(event) {
        const index = event.target.dataset.index;
        this.currentSlideIndexImpact = parseInt(index);
    }

    previousSlideImpact() {
        if (this.currentSlideIndexImpact > 0) {
            this.currentSlideIndexImpact--;
        }
    }

    nextSlideImpact() {
        console.log('currentSlideIndexImpact--->'+this.currentSlideIndexImpact);
        console.log('carouselItemsImpact.length--->'+this.carouselItemsImpact.length);
        console.log('visibleSlidesImapct--->'+this.visibleSlidesImapct);
        if (this.currentSlideIndexImpact < (this.visibleSlidesImapct - this.carouselItemsImpact.length)) {
            this.currentSlideIndexImpact++;
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

    openLoginPage() {
        this.loginPage = true;
    }
    openMenu() {
        this.isMenuOpen = true;
    }

    closeMenu() {
        this.isMenuOpen = false;
    }
    SearchMenuOpen() {
        this.isSearchMenuOpen = true;
    }

    closeSearchMenu() {
        this.isSearchMenuOpen = false;
    }

    toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }

    toggleDropdownAbout() {
        this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
    }
    connectedCallback() {
        Promise.all([
            loadStyle(this, LendWithCareJSCss + '/bootstrap.min.css'),
            loadStyle(this, LendWithCareJSCss + '/css2.css'),
            loadStyle(this, LendWithCareJSCss + '/slick.css'),
            loadStyle(this, LendWithCareJSCss + '/slick-theme.css'),
        ])
            .then(() => {
                Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-1.11.0.min.js')]).then(() => {
                    Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-migrate-1.2.1.min.js')]).then(() => {
                        Promise.all([loadScript(this, LendWithCareJSCss + '/bootstrap.bundle.min.js')]).then(() => {
                            Promise.all([loadScript(this, LendWithCareJSCss + '/slick.min.js')]).then(() => {
                                console.log("All scripts and CSS are loaded. perform any initialization function.");
                            });
                        });
                    });
                });
            })
            .catch(error => {
                console.log("failed to load the scripts:", error);
            });
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        
    }
   
}