import { LightningElement,track,wire} from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class CareAboutUsMicrofinancingHeader extends LightningElement {

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
aboutmicrofinancebody;
ulPresent = false;
val1;
val2;

 @wire(LWCSectionMetaData, { category: 'aboutmicrofinancingpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire aboutmicrofinance page 1st section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "About Microfinance") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ About in val1:', this.val1); // in black colour
            console.log('@@@ Microfinance in val2:', this.val2); // in yellow colour

        } else if (error) {
            // Handle error
        }
    }

get backgroundImage() {

    this.getScreenSize();

    
    
    if(this.screenWidth <= 600){
        return this.mobileimage;
        //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
    }
    else{
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
    getCMSContent(){
        this.spin = true;
        getContent({channelName:this.sectionName}).then( res=>{
            var r = JSON.parse(res);
            console.log( r );
            if( r!=undefined ){
                for( var val of r.items ){
                    if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined){
                        if(val.contentNodes.Tag.value == 'AboutMicrofinanceSection'){
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                           /*body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' ');
                            body = body.replaceAll('h3&gt;','');
                            body = body.replaceAll('&#39;','\'');
                            var aboutmicrofinancebody = body.split('/');
                            console.log('@@@ aboutmicrofinancebody length: ', aboutmicrofinancebody.length);
                            var aboutmicrofinancearray = [];
                            var storeobj='';
                            for( var i=0; i<aboutmicrofinancebody.length; i++ ){
                                 storeobj=aboutmicrofinancebody[i];
                                console.log('@@@ storeobj value', storeobj);
                                 aboutmicrofinancearray.push(storeobj);
                                 //console.log('@@@ about Value:',a1);
                            }
                            this.aboutmicrofinancebody= aboutmicrofinancearray;*/
                            this.aboutmicrofinancebody = body;
                            console.log('@@@ aboutmicrofinancebody Value:', this.aboutmicrofinancebody);
                           
                            this.desktopimage = this.imgUrl+val.contentNodes.Image.url;
                                /*var title = val.contentNodes.Title.value;
                                if( title!=undefined ){
                                    var titles = title.split(' ');
                                    var titleContent = '';
                                    console.log('@@@ Title:',val.contentNodes.Title.value);
                                    var a = [];
                                    var obj = {};
                                    for( var i=0; i<titles.length; i++ ){
                                        if( i == 0 || i%2 == 0 ){
                                            obj.white = titles[i];
                                        } else{
                                            obj.yellow = titles[i];
                                            a.push( obj );
                                            obj={};
                                        }
                                    }
                                    console.log('@@@ Title Value:',a);
                                    this.titles = a;
                                }*/
                        }
                       if( val.contentNodes.Tag.value == 'AboutMicrofinance-Mobile' ){
                            this.mobileimage = this.imgUrl+val.contentNodes.Image.url;
                        }
                        
                        this.getScreenSize();
                    }
                }
            }
            this.spin = false;
        }).catch( err=>{
            this.spin = false;
            console.log(err);
        } );
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