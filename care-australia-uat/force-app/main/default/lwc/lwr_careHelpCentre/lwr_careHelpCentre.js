import { LightningElement, track,wire } from 'lwc';
// import ABTMOBbanner from '@salesforce/resourceUrl/ABTMOBbanner';
// import AboutUsBanners from '@salesforce/resourceUrl/AboutUsBanners';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
// import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';
// import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import basePath from '@salesforce/community/basePath';

export default class Lwr_careHelpCentre extends LightningElement {
  @track screenWidth;
  @track screenHeight;

  showLoansAndLending = false;
  showPaymentsWithdrawals = false;
  showHowItworks = false;
  showMiscellaneous = false;
  showFAQs = false;
  imgUrl = basePath + '/sfsites/c';

  spin = false;
  @track isOpen1 = false;
  @track isOpen2 = false;
  @track isOpen3 = false;
  @track isOpen4 = false;
  @track isOpen5 = false;
  @track isOpen6 = false;
  @track isOpen7 = false;
  @track isOpen8 = false;
  @track isOpen9 = false;
  @track isOpen10 = false;
  @track isOpen11 = false;
  @track isOpen12 = false;
  @track isOpen13 = false;
  @track isOpen14 = false;
  @track isOpen15 = false;
  @track isOpen16 = false;

  helpcenterbody;
  titles;
  titles2;
  titles3;
  titles4;
  titles5;
  titles6;
  desktopimage;
  loanlendingvalues;
  paymentWithdrawlsvalues;
  howItWorksvalues;
  miscellaneousvalues;
  faqsvalues;
  contactUsBody;
  val1;
  val2;

  @wire(LWCSectionMetaData, { category: 'helpcentrepage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire helpcentrepage');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Help centre") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ centre in val1:', this.val1); 
            console.log('@@@ Help in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
    }

  get arrowIcon() {
    return this.isOpen1 ? '∧' : '∨';
  }

  toggleSection() {
    this.isOpen1 = !this.isOpen1;
  }
  get arrowIcon2() {
    return this.isOpen3 ? '∧' : '∨';
  }

  toggleSection2() {
    this.isOpen3 = !this.isOpen3;
  }

  get arrowIcon1() {
    return this.isOpen2 ? '∧' : '∨';
  }

  toggleSection1() {
    this.isOpen2 = !this.isOpen2;
  }
  get arrowIcon3() {
    return this.isOpen4 ? '∧' : '∨';
  }

  toggleSection3() {
    this.isOpen4 = !this.isOpen4;
  }
  get arrowIcon4() {
    return this.isOpen5 ? '∧' : '∨';
  }

  toggleSection4() {
    this.isOpen5 = !this.isOpen5;
  }
  get arrowIcon5() {
    return this.isOpen6 ? '∧' : '∨';
  }

  toggleSection5() {
    this.isOpen6 = !this.isOpen6;
  }
  get arrowIcon6() {
    return this.isOpen7 ? '∧' : '∨';
  }

  toggleSection6() {
    this.isOpen7 = !this.isOpen7;
  }
  get arrowIcon7() {
    return this.isOpen8 ? '∧' : '∨';
  }

  toggleSection7() {
    this.isOpen8 = !this.isOpen8;
  }
  get arrowIcon8() {
    return this.isOpen9 ? '∧' : '∨';
  }

  toggleSection8() {
    this.isOpen9 = !this.isOpen9;
  }
  get arrowIcon9() {
    return this.isOpen10 ? '∧' : '∨';
  }

  toggleSection9() {
    this.isOpen10 = !this.isOpen10;
  }
  get arrowIcon10() {
    return this.isOpen11 ? '∧' : '∨';
  }

  toggleSection10() {
    this.isOpen11 = !this.isOpen11;
  }
  get arrowIcon11() {
    return this.isOpen12 ? '∧' : '∨';
  }

  toggleSection11() {
    this.isOpen12 = !this.isOpen12;
  }
  get arrowIcon12() {
    return this.isOpen13 ? '∧' : '∨';
  }

  toggleSection12() {
    this.isOpen13 = !this.isOpen13;
  }
  get arrowIcon13() {
    return this.isOpen14 ? '∧' : '∨';
  }

  toggleSection13() {
    this.isOpen14 = !this.isOpen14;
  }
  get arrowIcon14() {
    return this.isOpen15 ? '∧' : '∨';
  }

  toggleSection14() {
    this.isOpen15 = !this.isOpen15;
  }
  get arrowIcon15() {
    return this.isOpen16 ? '∧' : '∨';
  }

  toggleSection15() {
    this.isOpen16 = !this.isOpen16;
  }

  get backgroundImage() {

    this.getScreenSize();

    /* if (this.screenWidth <= 414 && this.screenHeight <= 915) {
      return ABTMOBbanner;
      //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
    }
    else {
      return AboutUsBanners;
      //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
    } */

  }
  connectedCallback() {
    /* Promise.all([
      loadStyle(this, LendWithCareJSCss + '/bootstrap.min.css'),
      loadStyle(this, LendWithCareJSCss + '/css2.css'),
      loadStyle(this, LendWithCareJSCss + '/slick.css'),
      loadStyle(this, LendWithCareJSCss + '/slick-theme.css'),
    ])
      .then(() => {
        Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-1.11.0.min.js')]).then(() => {
          Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-migrate-1.2.1.min.js')]).then(() => {
            Promise.all([loadScript(this, LendWithCareJSCss + '/bootstrap.bundle.min.js')]).then(() => {
              Promise.all([loadScript(this, LendWithCareJSCss + '/slick.min.js')]).then(() => {
                console.log("All scripts and CSS are loaded. perform any initialization function.");
              });
            });
          });
        });
      })
      .catch(error => {
        console.log("failed to load the scripts:", error);
      }); */
    this.getScreenSize();
    window.addEventListener('resize', this.getScreenSize.bind(this));
    this.getCMSContent();
  }

  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }
  htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, 'text/html');
    let parsedstring = doc.documentElement.textContent;

    return parsedstring;
}
  sectionName = 'Why LWC';
  allContent = [];
  getCMSContent() {
    this.spin = true;
    getContent({ channelName: this.sectionName }).then(res => {
      var r = JSON.parse(res);
      console.log(r);
      console.log('test');
      console.log(JSON.stringify(r));
      if (r != undefined) {
        var loanLendings = [];
        var paymentWithdrawls = [];
        var howItWorks = [];
        var miscellaneous = [];
        var faqs = [];

        var i = 1;
        var itemContent = {};
        for (var val of r.items) {
          if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
            
            /* if (val.contentNodes.Tag.value == 'HC-ContactUs') {
                var body = val.contentNodes.Body.value;
                body = body.replaceAll('&lt;','');
                body = body.replaceAll('/p&gt;','');
                body = body.replaceAll('p&gt;','');
                body = body.replaceAll('&amp;','');
                body = body.replaceAll('br&gt;','');
                body = body.replaceAll('nbsp;',' ');
                body = body.replaceAll('amp;','&');
                body = body.replaceAll('h3&gt;','');
                body = body.replaceAll( 'a href=&quot;', '<a style="color:white;" href="' );
                body = body.replaceAll( '&quot; target=&quot;_blank&quot;&gt;', '" target="_blank">' );
                body = body.replaceAll('u&gt;','');
                body = body.replaceAll( 'a&gt;./', '</a>.' );
                console.log('COBODY:', body);
                /* body = body.replaceAll('Here/', 'Here');
                body = body.replaceAll('</a>/', ',</a>');
                this.hereA = body.substring(body.indexOf('<a')); --
                body = body.replaceAll('contact us//','contact us');
                this.template.querySelector('.contactUsBody').innerHTML = body;
            } */

            
            if (val.contentNodes.Tag.value == 'Helpcentre') {
              this.desktopimage = this.imgUrl+val.contentNodes.Image.url;
              console.log('@@@ Header Image part :', this.desktopimage);
              /*var title = val.contentNodes.Title.value;
              console.log('@@@ Title part :', title);
              if (title != undefined) {
                var titles = title.split(' ');
                //var titleContent = '';
                console.log('@@@ Title after split :', titles);
                var a = [];
                var obj = {};
                var wh = '';
                var yl = '';
                for (var i = 0; i < titles.length; i++) {
                  if (i == 0) {
                    wh += titles[i] + " ";
                    console.log('white title: ', wh);
                    obj.white = wh;
                  } else {
                    yl += titles[i] + " ";
                    console.log('yellow title: ', yl);
                    obj.yellow = yl;

                  }
                }
                a.push(obj);
                obj = {};
                console.log('@@@ Title Value:', a);
                this.titles = a;
              }*/
              var body = this.htmlDecode(val.contentNodes.Body.value);
              /* console.log('@@@ body part:', body);
              body = body.replaceAll('&lt;', '');
              body = body.replaceAll('/p&gt;', '');
              body = body.replaceAll('p&gt;', '');
              body = body.replaceAll('&amp;', '');
              body = body.replaceAll('br&gt;', '');
              body = body.replaceAll('nbsp;', ' ');
              body = body.replaceAll('h3&gt;', '');
              body = body.replaceAll('/h3&gt;', '');
              body = body.replaceAll('/', '');
              body = body.replaceAll('&#39;', '\''); */
              this.helpcenterbody = body.replaceAll('target="_blank"','target="_self"');
              console.log('@@@ help center body: ', this.helpcenterbody);

            } else if( val.contentNodes.Tag.value == 'HelpCentreItem' ){
              var ibody = this.htmlDecode(val.contentNodes.Body.value);
              var ititle = this.htmlDecode(val.contentNodes.Title.value);
              var icategory = this.htmlDecode(val.contentNodes.Category.value);
              var order = val.contentNodes.SortOrder != undefined && val.contentNodes.SortOrder.value != undefined ? val.contentNodes.SortOrder:100;
              var iCont = itemContent[icategory];
              if( iCont == undefined ){
                itemContent[icategory] = {'category':icategory, 'items':[]};
              }
              itemContent[icategory].items.push(  { 'title':ititle, 'body':ibody, 'category':icategory, 'idx':order,'toggleopen':false, 'arrowIcon':'∨' } );
              // itemContent.push( item );
            }
          }

        }
        if( itemContent!=undefined ){
          /* itemContent.sort((a, b) => {
            return a.idx - b.idx;
          }); */
          var arr = [];
          for( var val in itemContent ){
            console.log('AALLL1:',val,itemContent[val] );
            arr.push( itemContent[val] );
          }
          this.allContent = arr;
          console.log( 'AALLL2:',this.allContent );
          console.log( 'AALLL3:',itemContent );
        }
      }
      this.spin = false;
    }).catch(e => {
      this.spin = false;
      console.log('OUTPUT : ', e.toString());
      console.log('OUTPUT : ', e);
    })



  }
  handleToggle( event ){
    var idx= event.currentTarget.dataset.index;
    var outIdx= event.currentTarget.dataset.outidx;
    console.log( idx, outIdx );
    if( this.allContent!=undefined && this.allContent.length > outIdx ){
      var arr = [];
      for( var val of this.allContent ){
        arr.push(val);
      }
      var item = arr[outIdx];
      if( item!=undefined ){
        console.log( 'item:',item );
        var innerItem = item.items[idx];
        console.log( 'inItem:',innerItem );
        if( !innerItem.toggleopen ){
          innerItem.toggleopen = true;
          innerItem.arrowIcon = '∧';
        } else{
          innerItem.toggleopen = false;
          innerItem.arrowIcon = '∨';
        }
        this.allContent = arr;
      }
    }
  }
  loanlendingToggle(event){
    var idx= event.currentTarget.dataset.index;
    var arr= [];
    for(var val of this.loanlendingvalues){
      arr.push(val)
    }
    var open= arr[idx].toggleopen
    arr[idx].toggleopen=!open;
    if( arr[idx].toggleopen ){
        arr[idx].arrowIcon = '∧';
    } else{
      arr[idx].arrowIcon = '∨';
    }
    this.loanlendingvalues=arr;
    console.log( 'Inside:',this.loanlendingvalues )
  }
  paymentwithdrawlToggle(event){
    var idx= event.currentTarget.dataset.index;
    var arr= [];
    for(var val of this.paymentWithdrawlsvalues){
      arr.push(val)
    }
    var open= arr[idx].toggleopen
    arr[idx].toggleopen=!open
    if( arr[idx].toggleopen ){
        arr[idx].arrowIcon = '∧';
    } else{
      arr[idx].arrowIcon = '∨';
    }
    this.paymentWithdrawlsvalues=arr;
    console.log( 'Inside:',this.paymentWithdrawlsvalues )
  }
  howitworksToggle(event){
    var idx= event.currentTarget.dataset.index;
    var arr= [];
    for(var val of this.howItWorksvalues){
      arr.push(val)
    }
    var open= arr[idx].toggleopen
    arr[idx].toggleopen=!open
    if( arr[idx].toggleopen ){
        arr[idx].arrowIcon = '∧';
    } else{
      arr[idx].arrowIcon = '∨';
    }
    this.howItWorksvalues=arr;
    console.log( 'Inside:',this.howItWorksvalues )
  }
  miscellaneousToggle(event){
    var idx= event.currentTarget.dataset.index;
    var arr= [];
    for(var val of this.miscellaneousvalues){
      arr.push(val)
    }
    var open= arr[idx].toggleopen
    arr[idx].toggleopen=!open
    if( arr[idx].toggleopen ){
        arr[idx].arrowIcon = '∧';
    } else{
      arr[idx].arrowIcon = '∨';
    }
    this.miscellaneousvalues=arr;
    console.log( 'Inside:',this.miscellaneousvalues )
  }
  faqsToggle(event){
    var idx= event.currentTarget.dataset.index;
    var arr= [];
    for(var val of this.faqsvalues){
      arr.push(val)
    }
    var open= arr[idx].toggleopen
    arr[idx].toggleopen=!open
    if( arr[idx].toggleopen ){
        arr[idx].arrowIcon = '∧';
    } else{
      arr[idx].arrowIcon = '∨';
    }
    this.faqsvalues=arr;
    console.log( 'Inside:',this.faqsvalues )
  }
  

  gotoContactUsPage(){
    // window.location.assign('carecontactus');
    location.assign('carecontactus');
  }
}