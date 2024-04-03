import { LightningElement, track } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';

export default class Lwr_whoDoesCAREAustraliaWorkWith extends LightningElement {
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
    para4section;
    ulPresent = false;

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

                        if (val.contentNodes.Tag.value == 'Para4Section') {
                            //var body = val.contentNodes.Body.value;
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' ');
                            body = body.replaceAll('amp;','&');
                            body = body.replaceAll('h3&gt;','');
                            var para4sectionbody = body.split('/');
                            console.log('@@@ para4sectionbody length: ', para4sectionbody.length);
                            var para4sectionarray = [];
                            var storeobj4='';
                            for( var i=0; i<para4sectionbody.length; i++ ){
                                 storeobj4=para4sectionbody[i];
                                //console.log('@@@ storeobj4 value', storeobj4);
                                if( storeobj4 != '' && storeobj4 != undefined ) 
                                 para4sectionarray.push(storeobj4);
                                 //console.log('@@@ para4sectionarray Value:',para4sectionarray);
                            } 
                            para4sectionbody= para4sectionarray;*/
                            var para4sectionbody = body;
                            console.log('@@@ para4sectionbody Value:', para4sectionbody);

                            this.para4section = { 'title': val.contentNodes.Title.value, 'body': para4sectionbody, 'image': this.imgUrl + val.contentNodes.Image.url };
                            console.log('@@@ para4section :', this.para4section);
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
    /*penLoginPage(){
           this.loginPage = true;
       }
     openMenu(){
           this.isMenuOpen = true;
       }
   
       closeMenu(){
           this.isMenuOpen = false;
       }
       SearchMenuOpen(){
           this.isSearchMenuOpen = true;
       }
   
       closeSearchMenu(){
           this.isSearchMenuOpen = false;
       }
   
       toggleDropdown(){
       this.isDropdownOpen = !this.isDropdownOpen;
     }
   
         toggleDropdownAbout(){
       this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
     }*/
}