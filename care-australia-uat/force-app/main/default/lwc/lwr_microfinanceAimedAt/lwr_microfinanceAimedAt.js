import { LightningElement, track, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class Lwr_microfinanceAimedAt extends LightningElement {
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
    //aboutmicrofinance;
    para2section;
    aboutmicrofinancebody;
    ulPresent = false;
    val1;
    val2;

    @wire(LWCSectionMetaData, { category: 'aboutmicrofinancingpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire aboutmicrofinance page 2nd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Who is microfinance aimed at?") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ About in val1:', this.val1); // in black colour
            console.log('@@@ Microfinance in val2:', this.val2); // in black colour

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

                        if (val.contentNodes.Tag.value == 'Para2Section') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /*body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' ');
                            body = body.replaceAll('amp;','&');
                            body = body.replaceAll('h3&gt;','');
                            var para2sectionbody = body.split('/');
                            console.log('@@@ para2sectionbody length: ', para2sectionbody.length);
                            var para2sectionarray = [];
                            var storeobj2='';
                            for( var i=0; i<para2sectionbody.length; i++ ){
                                 storeobj2=para2sectionbody[i];
                                //console.log('@@@ storeobj2 value', storeobj2);
                                if( storeobj2!=''&&storeobj2!=undefined )
                                 para2sectionarray.push(storeobj2);
                                 //console.log('@@@ para2sectionarray Value:',para2sectionarray);
                            } 
                            para2sectionbody= para2sectionarray;*/
                            var para2sectionbody = body;
                            console.log('@@@ para2sectionbody Value:', para2sectionbody);

                            //'title':val.contentNodes.Title.value,
                            this.para2section = { 'body': para2sectionbody, 'image': this.imgUrl + val.contentNodes.Image.url };
                            console.log('@@@ para2section :', this.para2section);
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
    /*openLoginPage(){
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