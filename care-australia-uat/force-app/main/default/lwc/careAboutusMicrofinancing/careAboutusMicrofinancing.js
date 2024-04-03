import { LightningElement,track } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
export default class CareAboutUsMicrofinancingDev extends LightningElement {
 @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;

spin = false;

desktopimage;
mobileimage;
//aboutmicrofinance;
para2section;
para3section;
para4section;
para5section;
titles;
aboutmicrofinancebody;
ulPresent = false;

get backgroundImage() {

    this.getScreenSize();

    
    
    if(this.screenWidth <= 414 && this.screenHeight <= 915){
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
                            var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;','');
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
                            this.aboutmicrofinancebody= aboutmicrofinancearray;
                            console.log('@@@ aboutmicrofinancebody Value:', this.aboutmicrofinancebody);
                           
                            this.desktopimage = val.contentNodes.Image.url;
                                var title = val.contentNodes.Title.value;
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
                                }
                        }
                       if( val.contentNodes.Tag.value == 'AboutMicrofinance-Mobile' ){
                            this.mobileimage = val.contentNodes.Image.url;
                        }
                        if(val.contentNodes.Tag.value == 'Para2Section'){
                            var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;','');
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
                            para2sectionbody= para2sectionarray;
                            console.log('@@@ para2sectionbody Value:',para2sectionbody);

                            this.para2section = { 'title':val.contentNodes.Title.value, 'body':para2sectionbody, 'image':val.contentNodes.Image.url };
                            console.log('@@@ para2section :', this.para2section);
                        }
                        if(val.contentNodes.Tag.value == 'Para3Section'){
                            var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;','');
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
                            para3sectionbody= para3sectionarray;
                            console.log('@@@ para3sectionbody Value:',para3sectionbody);


                            this.para3section = { 'title':val.contentNodes.Title.value, 'body':para3sectionbody, 'link':val.contentNodes.Link.value };
                            console.log('@@@ para3section :', this.para3section);
                        }
                        if(val.contentNodes.Tag.value == 'Para4Section'){
                            var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;','');
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
                            para4sectionbody= para4sectionarray;
                            console.log('@@@ para4sectionbody Value:',para4sectionbody);

                            this.para4section = { 'title':val.contentNodes.Title.value, 'body':para4sectionbody, 'image':val.contentNodes.Image.url };
                            console.log('@@@ para4section :', this.para4section);
                        }
                        if(val.contentNodes.Tag.value == 'Para5Section'){
                            var body = val.contentNodes.Body.value;
                            console.log('PARA5:', body);
                            body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' ');
                            body = body.replaceAll('amp;','&');
                            body = body.replaceAll('h3&gt;','');
                            // body = body.replaceAll('li&gt;','&#x2022;');
                            var para5sectionbody = body.split('/');
                            console.log('@@@ para5sectionbody length: ', para5sectionbody.length);
                            var para5sectionarray = [];
                            var storeobj5='';
                            for( var i=0; i<para5sectionbody.length; i++ ){
                                 storeobj5=para5sectionbody[i];
                                //console.log('@@@ storeobj5 value', storeobj5);
                                if( storeobj5!='' && storeobj5!=undefined ){
                                    var obj = {'ul':false};
                                    if( storeobj5.includes('ul&gt;') || storeobj5.includes('li&gt;') ){
                                        this.ulPresent = true;
                                        obj.ul = true;
                                    }
                                    storeobj5 = storeobj5.replaceAll('li&gt;','');
                                    storeobj5 = storeobj5.replaceAll('ul&gt;','');
                                    if( storeobj5!='' && storeobj5!=undefined && storeobj5!='\n' ){
                                        obj['value'] = storeobj5;
                                        para5sectionarray.push(obj);
                                    }
                                } 
                                 //console.log('@@@ para5sectionarray Value:',para5sectionarray);
                            } 
                            para5sectionbody= para5sectionarray;
                            console.log('@@@ para5sectionbody Value:',para5sectionbody);

                            // var indices=[];
                            // var findindex = 'ul&gt;';
                            // var currentIndex = para5sectionbody.indexOf(findindex);
                              /* console.log('@@@ ul&gt; currentIndex :', currentIndex);
                            while (currentIndex !== -1) {
                                indices.push(currentIndex);
                                currentIndex = para5sectionbody.indexOf(findindex, currentIndex + 1);
                            }

                             console.log('@@@ ul&gt; index number :', indices); */

                            this.para5section = { 'title':val.contentNodes.Title.value, 'body':para5sectionbody };
                            console.log('@@@ para5section :', this.para5section);
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
  openLoginPage(){
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
  }
}