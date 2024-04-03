import { LightningElement, track, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';
import youtubeLink_lwrsite from "@salesforce/label/c.youtubelink_lwrsite";

export default class Lwr_institutionsProvideMicrofinance extends LightningElement {
    /*@track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;*/

    @track screenWidth;
    @track screenHeight;
    imgUrl = basePath + '/sfsites/c';
    spin = false;
    desktopimage;
    mobileimage;
    para3section;
    ulPresent = false;
    val1;
    val2;
    youtubelink=youtubeLink_lwrsite;

    @wire(LWCSectionMetaData, { category: 'aboutmicrofinancingpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire aboutmicrofinance page 3rd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "What kinds of institutions") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ What kinds of institutions in val1:', this.val1); // in black colour
            console.log('@@@ provide microfinance services? in val2:', this.val2); // in black colour

        } else if (error) {
            // Handle error
        }
    }

    get backgroundImage() {

        this.getScreenSize();
        if (this.screenWidth <= 414 && this.screenHeight <= 915) {
            return this.mobileimage;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return this.desktopimage;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }
    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
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

                        if (val.contentNodes.Tag.value == 'Para3Section') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' ');
                            body = body.replaceAll('h3&gt;','');
                            var para3sectionbody = body.split('/');
                            console.log('@@@ para3sectionbody length: ', para3sectionbody.length);
                            var para3sectionarray = [];
                            var storeobj3='';
                            for( var i=0; i<para3sectionbody.length; i++ ){
                                 storeobj3=para3sectionbody[i];
                                //console.log('@@@ storeobj3 value', storeobj3);
                                if( storeobj3 != '' && storeobj3 != undefined ) 
                                para3sectionarray.push(storeobj3);
                                 //console.log('@@@ para3sectionarray Value:',para3sectionarray);
                            } 
                            para3sectionbody= para3sectionarray;*/
                            var para3sectionbody = body;
                            console.log('@@@ para3sectionbody Value:', para3sectionbody);

                            //'title':val.contentNodes.Title.value, 
                            this.para3section = { 'body': para3sectionbody, 'link': val.contentNodes.Link.value };
                            console.log('@@@ para3section :', this.para3section);
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
}