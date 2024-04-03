import { LightningElement, track, wire } from 'lwc';
//import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';


export default class Lwr_careAboutUsHeader extends LightningElement {
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

    @wire(LWCSectionMetaData, { category: 'homepage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            // var val1 = '';
            // var val2 = '';

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "AboutUs") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ val1:', this.val1);
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
    getCMSContent() {
        this.spin = true;
        getContent({ channelName: this.sectionName }).then(res => {
            console.log('GOT CMS About LWC');
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                        if (val.contentNodes.Tag.value == 'AboutLendwithcare') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            //body = body.replaceAll('&#39;','\'');
                            var aboutlendwithcarebody = body.split('/');
                            console.log('@@@ aboutlendwithcarebody length: ', aboutlendwithcarebody.length);
                            var aboutlendwithcarearray = [];
                            var storeobj = '';
                            for (var i = 0; i < aboutlendwithcarebody.length; i++) {
                                storeobj = aboutlendwithcarebody[i];
                                console.log('@@@ storeobj value', storeobj);
                                aboutlendwithcarearray.push(storeobj);
                                //console.log('@@@ about Value:',a1);
                            }
                            this.aboutlendwithcarebody = aboutlendwithcarearray;*/
                            this.aboutlendwithcarebody = body.replaceAll('target="_blank"','target="_self"');;
                            console.log('@@@ aboutlendwithcarebody Value:', this.aboutlendwithcarebody, this.imgUrl+'---- '+val.contentNodes.Image.url);

                            this.desktopimage = this.imgUrl+val.contentNodes.Image.url;
                            /*var title = val.contentNodes.Title.value;
                            if (title != undefined) {
                                var titles = title.split(' ');
                                var titleContent = '';
                                console.log('@@@ Title:', val.contentNodes.Title.value);
                                var a = [];
                                var obj = {};
                                for (var i = 0; i < titles.length; i++) {
                                    if (i == 0 || i % 2 == 0) {
                                        obj.white = titles[i];
                                    } else {
                                        obj.yellow = titles[i];
                                        a.push(obj);
                                        obj = {};
                                    }
                                }
                                console.log('@@@ Title Value:', a);
                                this.titles = a;
                            }*/
                        }
                        if (val.contentNodes.Tag.value == 'AboutLendwithcare-Mobile') {
                            this.mobileimage = this.imgUrl+val.contentNodes.Image.url;
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
        // var currentPageUrl = window.location.href;
        var currentPageUrl = location.href;
        // currentPageUrl = currentPageUrl.substring(0, currentPageUrl.indexOf('/s') + 3);
        currentPageUrl = currentPageUrl.substring(0, currentPageUrl.indexOf('/s'));
        // window.location.href = currentPageUrl + 'aboutmicrofinancing';
       // location.href = currentPageUrl + 'aboutmicrofinancing';
       location.href = 'aboutmicrofinancing';
    }
}