import { LightningElement, track,wire } from 'lwc';

import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class CareOurImpactHeader extends LightningElement {

    @track screenWidth;
    @track screenHeight;
    desktopimage;
    mobileimage;
    imgUrl = basePath + '/sfsites/c';
    title1;
    impactbody;
      val1;
    val2;
    spinner=false;
    //@track isMenuOpen = false;
    //@track isSearchMenuOpen = false;
    //@track isDropdownOpen = false;
    //@track isDropdownOpenAbout = false;
    //@track loginPage = false;
    //title2;
    //title3;
    //title4;
    //empowerbody;
    //approachbody;
    //evidencebody;
    //image1;
    //image2;

    /*LenwithCareLogo = LWCLogo;
    chartcolors = ChartImg;
    lendLogo = LendWithCareImages + '/logo.png';
    ladyWithGreen = ladyWithGreen;
    greenFieldSlope = greenFieldSlope;
    img3 = img3;
    img5 = img5;
    img6 = img6;*/
  

    @wire(LWCSectionMetaData, { category: 'ourimpactpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire ourimpactpage 1st section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Impact") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Impact in val1:', this.val1); 
            console.log('@@@ Impact in val1:', this.val2);

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
    ];*/

   /* get sliderStylesImpact() {
        const translateXValue = this.currentSlideIndexImpact * (100 / this.visibleSlidesImapct);
        return `transform: translateX(-${translateXValue}%);`;
    }*/

    /*handleDotClickImpact(event) {
        const index = event.target.dataset.index;
        this.currentSlideIndexImpact = parseInt(index);
    }*/

    /*previousSlideImpact() {
        if (this.currentSlideIndexImpact > 0) {
            this.currentSlideIndexImpact--;
        }
    }*/

    /*nextSlideImpact() {
        if (this.currentSlideIndexImpact < this.carouselItemsImpact.length - this.visibleSlidesImapct) {
            this.currentSlideIndexImpact++;
        }
    }*/


    get backgroundImage() {

        this.getScreenSize();
        if (this.screenWidth <= 600) {
            return this.mobileimage;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return this.desktopimage;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }
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
    }*/
    /*openMenu() {
        this.isMenuOpen = true;
    }*/

    /*closeMenu() {
        this.isMenuOpen = false;
    */
    /*SearchMenuOpen() {
        this.isSearchMenuOpen = true;
    }*/

    /*closeSearchMenu() {
        this.isSearchMenuOpen = false;
    }*/

    /*toggleDropdown() {
        this.isDropdownOpen = !this.isDropdownOpen;
    }*/

    /*toggleDropdownAbout() {
        this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
    }*/
    connectedCallback() {
       /* Promise.all([
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
        this.spinner = true;
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                        
                        if (val.contentNodes.Tag.value == 'ourimpact-Mobile') {
                            this.mobileimage = this.imgUrl+val.contentNodes.Image.url;
                        }
                        if (val.contentNodes.Tag.value == 'Impactheader') {
                            this.desktopimage = this.imgUrl + val.contentNodes.Image.url;
                            console.log('@@@ image part :', this.desktopimage);

                            /*var title = val.contentNodes.Title.value;
                            this.title1 = title
                            console.log('@@@ Title part :', this.title1);*/
                            
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*var body = val.contentNodes.Body.value;
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
                            this.impactbody = body;
                            console.log('@@@ impact body: ', this.body);

                        } else if( val.contentNodes.Tag.value == 'TransactionEmail' ){
                            console.log('TE:',this.htmlDecode(val.contentNodes.Body.value));
                        }

                    }
                }
            }
            this.spinner = false;
        }).catch(e => {
            this.spinner = false;
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })

    }
}