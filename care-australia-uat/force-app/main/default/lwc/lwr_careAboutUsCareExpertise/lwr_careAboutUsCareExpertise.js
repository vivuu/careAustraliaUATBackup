import { LightningElement, track, wire } from 'lwc';
//import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class Lwr_careAboutUsCareExpertise extends LightningElement {
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
    titles;
    val1;
    val2;

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }

    @wire(LWCSectionMetaData, { category: 'aboutuspage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire aboutus page 3rd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            // var val1 = '';
            // var val2 = '';

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Our expertise in microfinance") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Our expertise in microfinance in val1:', this.val1); // in black colour
            console.log('@@@ val2:', this.val2);

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
    }
    sectionName = 'Why LWC';
    microLink='';
    getCMSContent() {
        this.spin = true;
        getContent({ channelName: this.sectionName }).then(res => {
            console.log('GOT CMS About LWC');
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                       
                        if (val.contentNodes.Tag.value == 'OurExpertiseSection') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            this.microLink = val.contentNodes.Link!=undefined ? val.contentNodes.Link.value :'';
                            /*var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('amp;', '&');
                            body = body.replaceAll('h3&gt;', '');
                            body = body.replaceAll('a href=&quot;', '<a href="');
                            body = body.replaceAll('&quot; target=&quot;_blank&quot;&gt;', '" target="_blank">');
                            body = body.replaceAll('a&gt;', '</a>');
                            console.log('BODY:', body);
                            body = body.replaceAll('Here/', 'Here');
                            body = body.replaceAll('</a>/', ',</a>');
                            this.hereA = body.substring(body.indexOf('<a'));
                            body = body.replaceAll(this.hereA, '');
                            console.log('BODY:', body);
                            var ourexpertisebody = body.split('&#92;n/');
                            console.log('@@@ ourexpertisebody length: ', ourexpertisebody.length);
                            var ourexpertisearray = [];
                            var storeobj2 = '';
                            for (var i = 0; i < ourexpertisebody.length; i++) {
                                storeobj2 = { 'value': ourexpertisebody[i], 'showHere': false };
                                if (i + 1 == ourexpertisebody.length) {
                                    storeobj2.showHere = true;
                                }
                                //console.log('@@@ storeobj2 value', storeobj2);
                                ourexpertisearray.push(storeobj2);
                                //console.log('@@@ ourexpertisearray Value:',ourexpertisearray);
                            }
                            ourexpertisebody = ourexpertisearray;
                            console.log('@@@ ourexpertisebody Value:', ourexpertisebody);*/
                            var updatedBody =body.replaceAll('target="_blank"','target="_self"');
                           var ourexpertisebody = updatedBody;
                            console.log('@@@ ourexpertisebody Value:', ourexpertisebody);
                            // 'title': val.contentNodes.Title.value, 
                            this.ourexpertisesection = { 'body': ourexpertisebody, 'btn': val.contentNodes.ButtonName.value, 'image': this.imgUrl+val.contentNodes.Image.url };
                            console.log('@@@ ourexpertisesection :', this.ourexpertisesection);
                        }
                        

                        this.getScreenSize();
                    }

                }

            }
            this.spin = false;
        }).catch(err=>{
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
        // window.location.href = this.microLink;
        location.href = this.microLink;
    }
}