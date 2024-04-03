import { LightningElement, track,wire } from 'lwc';
import basePath from '@salesforce/community/basePath';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class Lwr_careHomePage_whyLWC extends LightningElement {
    /*@track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;
    @api slidesData;*/

    @track screenWidth;
    @track screenHeight;
    val1;
    val2;
    allLoansUrl;
    imgUrl = basePath + '/sfsites/c';

    @wire(LWCSectionMetaData, { category: 'homepage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for why lwc');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            // var val1 = '';
            // var val2 = '';

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "WhyLwc") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ why in val1:', this.val1);
            console.log('@@@ lwc in val2:', this.val2);

        } else if (error) {
            // Handle error
        }
    }

    /*@track currentSlideIndex = 0;
    @track visibleSlides = 4;

    get sliderStyles() {
        const translateXValue = this.currentSlideIndex * (100 / this.visibleSlides);
        return `transform: translateX(-${translateXValue}%);`;
    }

    previousSlide() {
        if (this.currentSlideIndex > 0) {
            this.currentSlideIndex--;
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


    get backgroundImage() {

        this.getScreenSize();

    }
    whyLWCLists = [];
    btn1;
    sectionName = 'Why LWC';
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
    getCMSContent() {
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined &&
                        (val.contentNodes.Tag.value == 'WhyLWC-button' || val.contentNodes.Tag.value == 'WhyLWC')) {
                        var body = '';
                        if (val.contentNodes.Body != undefined) {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            // var body = val.contentNodes.Body.value;
                            /* body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('&#39;', '\''); */
                            console.log('Body:', body);
                        }
                        if (val.contentNodes.Tag.value == 'WhyLWC-button') {
                            console.log('Button1:', val);
                            var link = val.contentNodes.Link != undefined ? val.contentNodes.Link.value : '';
                            // var bUrl = window.location.href;
                            var bUrl = location.href;
                            bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
                            this.allLoansUrl = bUrl+link;
                            var oo = { 'title': val.contentNodes.Title.value, 'body': body, 'link': link };
                            this.btn1 = oo;
                            console.log('Button:', oo);
                        } else if (val.contentNodes.Tag.value == 'WhyLWC') {
                            i++;
                            console.log('-->', val);
                            if (val.contentNodes.Image != undefined) {
                                var obj = { 'title': val.title, 'body': body, 'img': this.imgUrl+val.contentNodes.Image.url, 'idx': parseInt(val.contentNodes.SortOrder.value) };
                                arr.push(obj);
                            }
                        }
                    }
                }
                if (arr.length > 0) {
                    arr.sort((a, b) => {
                        return a.idx - b.idx;
                    });
                    for (var i = 0; i < arr.length; i++) {
                        var size = 3;
                        if (i == 0 || (i + 1) % 4 == 0) {
                            size = 2;
                        }
                        arr[i].size = size;
                    }
                    this.whyLWCLists = arr;
                    console.log('why:', this.whyLWCLists);
                }
            }
        }).catch(e => {
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
    
   /* handleSlide(event) {
    
            //CC 2.0 License Iatek LLC 2018 - Attribution required
        
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
    openViewAllloans(){
        console.log(this.allLoansUrl);
        // window.location.href = this.allLoansUrl;
        location.href = this.allLoansUrl;
    }
}