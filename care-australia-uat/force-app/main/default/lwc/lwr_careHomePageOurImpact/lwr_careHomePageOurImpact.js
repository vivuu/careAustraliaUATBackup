import { LightningElement,track,wire } from 'lwc';
/*import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';*/
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';
export default class Lwr_careHomePageOurImpact extends LightningElement {
    @track screenWidth;
    @track screenHeight;
    displayPreviousButtom=false;
    displayNextButtom=true;
    firstFourItems = [];
    imgUrl = basePath + '/sfsites/c';
FONT_CSS_URL = 'https://hello.mystatic/fonts.net/count/3bca71';
     
    carouselItems = [];
    sectionName = 'Why LWC';
    description;
    val1;
    val2;
    blogpostUrl;
    
    @wire(LWCSectionMetaData, {category:'homepage'})
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if(data[i].MasterLabel=="OurImpact"){
                    this.val1= data[i].Value_1__c;
                    this.val2= data[i].Value_2__c;
                }
            }
            console.log('@@@ val1:',this.val1);
            console.log('@@@ val2:',this.val2);

            } else if (error) {
            // Handle error
        }
    }    
  connectedCallback() {
      try{
        /*Promise.all([
            loadStyle(this, LendWithCareJSCss + '/bootstrap.min.css'),
            loadStyle(this, LendWithCareJSCss + '/css2.css'),
            loadStyle(this, LendWithCareJSCss + '/slick.css'),
            loadStyle(this, LendWithCareJSCss + '/slick-theme.css'),
        ])
            .then(() => {
                Promise.all([loadScript(this, LendWithCareJSCss+'/jquery-1.11.0.min.js')]).then( ()=>{
                    Promise.all([loadScript(this, LendWithCareJSCss+'/jquery-migrate-1.2.1.min.js')]).then( ()=>{
                        Promise.all([loadScript(this, LendWithCareJSCss + '/bootstrap.bundle.min.js')]).then( ()=>{
                            Promise.all([loadScript(this, LendWithCareJSCss+'/slick.min.js')]).then( ()=>{
                                console.log("All scripts and CSS are loaded. perform any initialization function.");           
                            } ).catch(error => {
                console.log("failed to load the scripts:", error);
            });
                        } ).catch(error => {
                console.log("failed to load the scripts:", error);
            });
                    } ).catch(error => {
                console.log("failed to load the scripts:", error);
            });
                } ).catch(error => {
                console.log("failed to load the scripts:", error);
            })
            })
            .catch(error => {
                console.log("failed to load the scripts:", error);
            });*/
        this.getScreenSize();
        // var bUrl = window.location.href;
        var bUrl = location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.blogpostUrl = bUrl;
        console.log('@@@ blogpostUrl', this.blogpostUrl);
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
      } catch( err ){
          console.log('OUTPUT : ',err);
      }
  }
  htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;
    
        return parsedstring;
    }

  getCMSContent(){
      getContent({channelName:this.sectionName}).then( res=>{
          var r = JSON.parse(res);
          console.log( '@@@ res',r );
          if( r!=undefined ){
            var arr = [];
            var i = 1;
            for( var val of r.items ){
                if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined ){
                    if( val.contentNodes.Tag.value == 'Ourimpact' ){
                        console.log('@@@ Inside IF block for our impact');
                        //var location  = val.contentNodes.Location.value;
                        //console.log('@@@ Loation for our impact',location );
                        //console.log('@@@ Loation for our impact',val.contentNodes.Location.value );
                         var body = this.htmlDecode(val.contentNodes.Body.value);
                         var pubDate = val.publishedDate != undefined? new Date(val.publishedDate) : new Date();
                            /* body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            console.log('Body:',body);
                            var ourimpactbody = body.split('/');
                            console.log('@@@ ourimpactbody body after split:', ourimpactbody);
                            console.log('@@@ ourimpactbody body length: ', ourimpactbody.length);
                             var storeobj = '';
                             for(let j =0; j<1; j++ ){
                                 storeobj = storeobj+ourimpactbody[j];
                                 console.log('@@@ storeobj value', storeobj);
                             } */
                        /*var body = this.htmlDecode(this.htmlDecode(val.contentNodes.Body.value));
                        body = this.htmlDecode(this.htmlDecode(body));
                        body = body.replaceAll('&lt;','');
                        body = body.replaceAll('/p&gt;','');
                        body = body.replaceAll('p&gt;','');
                        
                        i++;
                        console.log('-->',val);*/
                        //body = this.htmlDecode(body);
                        body = body!=undefined && body.length>120? body.substring(0,120)+'...':body;
                        var contentkeyvalue = val.contentKey;
                        var imgBlog = '';
                         if (val.contentNodes.Image != undefined){
                            imgBlog = val.contentNodes.Image.url;
                        }
                        var linkValue = '';
                        if( val.contentNodes.Link!=undefined ){
                            console.log('-->',val.contentNodes.Link);
                            linkValue=val.contentNodes.Link.value;
                        }
                        var title = this.htmlDecode(val.title);
                        var idx = val.contentNodes.SortOrder!=undefined?val.contentNodes.SortOrder.value:100;
                        title = title.length > 35? title.substring(0,35)+'...' : title;
                        var location = val.contentNodes.Location!=undefined?val.contentNodes.Location.value:'';
                        var obj = {'title':title, 'pubDate':pubDate,'body':body, 'img':'background-image: url(\''+this.imgUrl+imgBlog+'\');background-size: cover; background-repeat: no-repeat;', 'button':val.contentNodes.ButtonName.value,
                        'button':val.contentNodes.ButtonName.value,'buttonlink':this.blogpostUrl +linkValue+ '?contentKey='+btoa(contentkeyvalue),'idx':parseInt(idx),
                        'location': location};
                         console.log('@@@ OBJ',obj);
                        arr.push(obj);
                    } else if( val.contentNodes.Tag.value == 'OurImpact-Title' ){
                        var title = this.htmlDecode(val.contentNodes.Body.value);
                        this.description = title;
                    }
                }
            }
            if( arr.length > 0 ){
                arr.sort((a, b) => {
                    return b.pubDate - a.pubDate;
                });
                for( var i = 0; i<arr.length; i++ ){
                    var size = 3;
                    if( i == 0 || (i+1)%4 == 0 ){
                        size = 2;
                    }
                    arr[i].size = size;
                }
                this.carouselItems = arr;
                this.carouselItems = this.carouselItems.slice(0, 4);
                this.firstFourItems = this.carouselItems.slice(0, 4);
                console.log('carousel Items-->'+ JSON.stringify(this.carouselItems));
            }
          }
      } ).catch(e=>{
          //console.log('OUTPUT : ',e.toString());
          console.log('OUTPUT : ',e);
      })
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }

  @track currentSlideIndexImpact = 0;
  @track visibleSlidesImpact = 4;

  get sliderStylesImpact() {
    const translateXValue = this.currentSlideIndexImpact * (112 / this.visibleSlidesImpact);
    console.log('transform-->'+`transform: translateX(-${translateXValue}%);`);
    return `transform: translateX(-${translateXValue}%);`;
  }

  get visibleCarouselItems() {
    return this.carouselItems.slice(this.currentSlideIndexImpact, this.currentSlideIndexImpact + this.visibleSlidesImpact);
  }

  previousSlideImpact() {
      console.log('currentSlideIndex Previous-->'+this.currentSlideIndexImpact);
    if (this.currentSlideIndexImpact > 0) {
      this.currentSlideIndexImpact--;
      this.displayNextButtom=true;
    }else if(this.currentSlideIndex == 0){
        this.displayNextButtom=true;
        this.displayPreviousButtom=false;
    }else{
        this.displayPreviousButtom=false;
    }
  }

  nextSlideImpact() {
      console.log('currentSlideIndex Next-->'+this.currentSlideIndexImpact);
      console.log('Carousel Length-->'+this.carouselItems.length);
    if (this.currentSlideIndexImpact < (8 - this.carouselItems.length) ) {
      this.currentSlideIndexImpact++;
      this.displayPreviousButtom=true;
    }else{
        this.displayNextButtom=false;
    }
  }

  handleDotClickImpact(event) {
    const index = parseInt(event.target.dataset.index);
    this.currentSlideIndexImpact = index;
  }

  get dotClass() {
    return this.carouselItems.map((item, index) =>
      index === this.currentSlideIndexImpact ? 'dotClass active' : 'dotClass'
    );
  }

}

  /*  @track screenWidth;
    @track screenHeight;
    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;
    @api slidesData;

    @track carouselItems = [
        {
            id: 1,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 1',
            description: 'This is the first slide of the carousel.'
        },
        {
            id: 2,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 2',
            description: 'This is the second slide of the carousel.'
        },
        {
            id: 3,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 3',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 4,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 4',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 5,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 5',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 6,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 6',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 7,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 7',
            description: 'This is the third slide of the carousel.'
        },
        {
            id: 8,
            imageUrl: LendWithCareImages+'/client1.png',
            title: 'Slide 8',
            description: 'This is the third slide of the carousel.'
        }
    ];

    slides=[
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Parichat Borrower'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Gowsic Nagarajan'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Partha Sarathy'
        },
        {
            image: `${LendWithCareImages}/client1.png`,
            heading: 'Lorem ipsum dolor sit amet consec tetur adipi scing elit rhon cusmi sed in amet.',
            description: 'Vivek Kulangathu'
        },
        
    ]

    profilepic = LendWithCareImages+'/client1.png';
    careLogo=LendWithCareImages+'/care.png';
    careLogos=LendWithCareImages+'/country.png';
    lendLogo=LendWithCareImages+'/logo.png';

    Working = working;
    Greenfield = greenfield;
    GWomen = Womenz;
   
    lendAgainImg = LendWithCareImages+'/lendagain.png';
    replyImg = LendWithCareImages+'/reply.png';
    growImg = LendWithCareImages+'/grow.png';
    yourLendImg = LendWithCareImages+'/yourlend.png';
    clientImg = LendWithCareImages+'/client1.png';
    checkcircles = LendWithCareImages+'/CheckCircle.png';
    testimonialBackground = LendWithCareImages+'/testimonialbg.png';
    banner = banner; //LendWithCareImages+'/banner.jpeg';
    banner1 =banner1  // LendWithCareImages+'/mobile-banner.png'; //mobileBanner;
    testi = LendWithCareImages+'/testimonialbg.jpeg';
    testi1 = testi1;

    @track currentSlideIndex = 0;
    @track visibleSlides = 4;

    get sliderStyles() {
        const translateXValue = this.currentSlideIndex * (100 / this.visibleSlides);
        return `transform: translateX(-${translateXValue}%);`;
    }

    get visibleCarouselItems() {
        return this.carouselItems.slice(this.currentSlideIndex, this.currentSlideIndex + this.visibleSlides);
    }

    previousSlide() {
        if (this.currentSlideIndex > 0) {
            this.currentSlideIndex--;
        }
    }

    nextSlide() {
        if (this.currentSlideIndex < this.carouselItems.length - this.visibleSlides) {
            this.currentSlideIndex++;
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

    SearchMenuOpen(){
        this.isSearchMenuOpen = true;
    }

    closeSearchMenu(){
        this.isSearchMenuOpen = false;
    }

    toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }

      toggleDropdownAbout() {
    this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
  }

    get testimoni(){
        
        if(this.screenWidth <= 414 && this.screenHeight <= 915){
        return `background-image: url('${this.testi1}');background-size: cover; background-repeat: no-repeat;Height:725px;`;
        }
        else{
            return `background-image: url('${this.testi}');background-size: cover; background-repeat: no-repeat;Height:546px;`;
        } 
    }

   get backgroundImage() {

    this.getScreenSize();
    
    if(this.screenWidth <= 414 && this.screenHeight <= 915){
        return `background-image: url('${this.banner1}');background-size: cover; background-repeat: no-repeat;`;
    }
    else{
        return `background-image: url('${this.banner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
    }
    
  }  
  connectedCallback() {
    this.getScreenSize();
    window.addEventListener('resize', this.getScreenSize.bind(this));
  }
  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }

    handleSlide(event) {
    
       // CC 2.0 License Iatek LLC 2018 - Attribution required
    
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