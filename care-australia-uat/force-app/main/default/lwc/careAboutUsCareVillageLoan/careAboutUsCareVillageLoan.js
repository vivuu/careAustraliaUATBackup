import { LightningElement, track, wire } from 'lwc';
//import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';


export default class CareAboutUsCareVillageLoan extends LightningElement {

    @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;

    imgUrl = basePath + '/sfsites/c';
    hereA;
    spin = false;
    aboutlendwithcare;
    aboutlendwithcarebody;
    careaustraliasection;
    ourexpertisesection;
    whataresection;
    desktopimage;
    mobileimage;
    //titles;
    val1;
    val2;
    changechampionUrl;

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }

    @wire(LWCSectionMetaData, { category: 'aboutuspage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire aboutus page 4th section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "WhatareVillageSavings") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ val1:', this.val1); // in black colour
            console.log('@@@ val2:', this.val2); // in black colour

        } else if (error) {
            // Handle error
        }
    }

    renderedCallback() {
        if (this.template.querySelector('.hereCl')) {
            this.hereA = this.hereA.replaceAll('Here,', 'Here');
            console.log('HERE:', this.hereA);
            this.template.querySelector('.hereCl').innerHTML = this.hereA;
        }
    }

    get backgroundImage() {

        this.getScreenSize();
        if (this.screenWidth <= 414 && this.screenHeight <= 915) {
            return this.mobileimage;
            //return ABTMOBbanner;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return this.desktopimage;
            //return AboutUsBanners;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }

    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
        var bUrl = window.location.href;
        bUrl = bUrl != undefined ? bUrl.substring(0, bUrl.lastIndexOf('/')) : '';
        this.changechampionUrl = bUrl;
        console.log('@@@ changechampionUrl', this.changechampionUrl);
    }
    sectionName = 'Why LWC';
    getCMSContent() {
        this.spin = true;
        getContent({ channelName: this.sectionName }).then(res => {
            console.log('GOT CMS About LWC');
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {

                        if (val.contentNodes.Tag.value == 'WhatAreSection') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('amp;', '&');
                            body = body.replaceAll('h3&gt;', '');
                            var whatarebody = body.split('/');
                            console.log('@@@ whatarebody length: ', whatarebody.length);
                            var whatarearray = [];
                            var storeobj3 = '';
                            for (var i = 0; i < whatarebody.length; i++) {
                                storeobj3 = whatarebody[i];
                                //console.log('@@@ storeobj3 value', storeobj3);
                                whatarearray.push(storeobj3);
                                //console.log('@@@ whatarearray Value:',whatarearray);
                            }
                            whatarebody = whatarearray;
                            console.log('@@@ whatarebody Value:', whatarebody);*/
                            var whatarebody = body;
                            console.log('@@@ whatarebody Value:', whatarebody);
                            var linkValue = '';
                            if (val.contentNodes.Link != undefined) {
                                linkValue = val.contentNodes.Link.value;
                                 console.log('@@@ Champion linkValue', val.contentNodes.Link);
                            }
                            //'title': val.contentNodes.Title.value.replaceAll('&amp;', '&'), 
                            this.whataresection = {
                                'body': whatarebody, 'image': this.imgUrl + val.contentNodes.Image.url, 'button': val.contentNodes.ButtonName.value,
                                'buttonlink': this.changechampionUrl + linkValue
                            };
                            console.log('@@@ whataresection :', this.whataresection);
                        }

                        this.getScreenSize();
                    }

                }

            }
            this.spin = false;
        }).catch(err => {
            this.spin = false;
            console.log(err);
        });
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
    handleMicroFinance() {
        var currentPageUrl = window.location.href;
        currentPageUrl = currentPageUrl.substring(0, currentPageUrl.indexOf('/s') + 3);
        window.location.href = currentPageUrl + 'aboutmicrofinancing';
    }

}