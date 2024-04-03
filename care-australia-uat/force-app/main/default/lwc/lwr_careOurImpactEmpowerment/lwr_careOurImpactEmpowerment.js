import { LightningElement, track,wire } from 'lwc';
/*import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import ladyWithGreen from '@salesforce/resourceUrl/ladyWithGreen';
import greenFieldSlope from '@salesforce/resourceUrl/greenFieldSlope';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';
import img5 from '@salesforce/resourceUrl/img5';
import img6 from '@salesforce/resourceUrl/img6';
import img3 from '@salesforce/resourceUrl/img3';
import LWCLogo from '@salesforce/resourceUrl/LWCLogoSvg';
import ChartImg from '@salesforce/resourceUrl/chartimage';
import OurImpactBanner from '@salesforce/resourceUrl/OurImpactBanner';
import OurImpactBanner1 from '@salesforce/resourceUrl/OurImpactMobileBan';*/

import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class Lwr_careOurImpactEmpowerment extends LightningElement {
    @track screenWidth;
    @track screenHeight;
    //title2;
    empowerbody;
    imgUrl = basePath + '/sfsites/c';
    val1;
    val2;

    /*@track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;*/

   //desktopimage;
    
    //title1;
   
    //title3;
    //title4;
    //impactbody;
    //approachbody;
    //evidencebody;
    //image1;
    //image2;

    //LenwithCareLogo = LWCLogo;
    //chartcolors = ChartImg;
    //lendLogo = LendWithCareImages + '/logo.png';
    //ladyWithGreen = ladyWithGreen;
    //greenFieldSlope = greenFieldSlope;
    //img3 = img3;
    //img5 = img5;
    //img6 = img6;
   

      @wire(LWCSectionMetaData, { category: 'ourimpactpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire ourimpactpage 2nd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Why Lendwithcare?") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Why Lendwithcare? in val1:', this.val1); 
            console.log('@@@ in val2:', this.val2);

        } else if (error) {
            // Handle error
        }
    }

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }


    /*@track carouselItemsImpact = [
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
        },
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
    ];

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
        if (this.currentSlideIndexImpact < this.carouselItemsImpact.length - this.visibleSlidesImapct) {
            this.currentSlideIndexImpact++;
        }
    }*/


    /*get backgroundImage() {

        this.getScreenSize();
        if (this.screenWidth <= 414 && this.screenHeight <= 915) {
            return OurImpactBanner1;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return OurImpactBanner;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }*/
    /*connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
    }*/
    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }

    /*openLoginPage() {
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
    }*/
    connectedCallback() {
        /*Promise.all([
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
            });*/
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    sectionName = 'Why LWC';
    getCMSContent() {
        this.spin = true;
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                        
                        if (val.contentNodes.Tag.value == 'Empowermentlabel') {
                           
                            /*var title = val.contentNodes.Title.value;
                            this.title2 = title
                            console.log('@@@ Title part :', this.title2);*/

                            var body = this.htmlDecode(val.contentNodes.Body.value);
                           /* var body = val.contentNodes.Body.value;
                            console.log('@@@ body part:', body);
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            body = body.replaceAll('/h3&gt;', '');
                            body = body.replaceAll('/', '');
                            body = body.replaceAll('&#39;', '\'');*/
                            this.empowerbody = body;
                            console.log('@@@ empower body: ', this.empowerbody);
                        }
                    }
                }
        }}).catch(e => {
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })
    }
}