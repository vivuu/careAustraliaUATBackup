import { LightningElement, track } from 'lwc';
/*import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import para2img from '@salesforce/resourceUrl/para2img';
import para3img from '@salesforce/resourceUrl/para3img';
import img5 from '@salesforce/resourceUrl/img5';
import img6 from '@salesforce/resourceUrl/img6';
import img3 from '@salesforce/resourceUrl/img3';
import ABTMOBbanner from '@salesforce/resourceUrl/ABTMOBbanner';
import AboutUsBanners from '@salesforce/resourceUrl/AboutUsBanners';
import carecontactus from '@salesforce/resourceUrl/carecontactus';*/
//import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';

export default class Lwr_careBlogPost extends LightningElement {
    spin = false;
  @track screenWidth;
  @track screenHeight;
  careblogposttitle;
  careblogpostimage;
  bodycareblogpost;
  contentKey;
  PublishedDatenew;
  imgUrl = basePath + '/sfsites/c';
  FONT_CSS_URL = 'https://hello.mystatic/fonts.net/count/3bca71';

  /*lendLogo = LendWithCareImages + '/logo.png';
  para3img = para3img;
  img3 = img3;
  img5 = img5;
  img6 = img6;
  carecontactus = carecontactus;*/

  /*get backgroundImage() {
    this.getScreenSize();
    if (this.screenWidth <= 414 && this.screenHeight <= 915) {
      return ABTMOBbanner;
      //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
    }
    else {
      return AboutUsBanners;
      //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
    }

  }*/

  // gotoNewsAndUpdates = window.location.href.substring(0, window.location.href.indexOf('/s')+3)+'newsandupdates';
  gotoNewsAndUpdates = 'newsandupdates';
  

  htmlDecode(input) {
    var doc = new DOMParser().parseFromString(input, 'text/html');
    let parsedstring = doc.documentElement.textContent;

    return parsedstring;
  }
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
  connectedCallback() {
    this.spin = true;
    this.getScreenSize();
    const tempId = 'contentKey';
    // this.contentKey = atob(this.getUrlParamValue(window.location.href, tempId));
    this.contentKey = atob(this.getUrlParamValue(location.href, tempId));
    console.log('@@@ contentKey value', this.contentKey);
    window.addEventListener('resize', this.getScreenSize.bind(this));
    this.getCMSContent();
  }
  sectionName = 'Why LWC';
  getCMSContent() {
    getContent({ channelName: this.sectionName }).then(res => {
      console.log('GOT CMS BLOG POST');
      var r = JSON.parse(res);
      console.log('@@@ res value', r);
      if (r != undefined) {
        for (var val of r.items) {
          //if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
          if (val.type == 'CareAustraliaSite' && val.contentKey != undefined) {
            if (val.contentKey == this.contentKey) {
              console.log('@@@ Inside IF');
              console.log('@@@val.contentKey', val.contentKey);
              console.log('@@@val.contentNodes', val.contentNodes);
              //console.log('@@@val.Created By', val.CreatedById);

              console.log('@@@val.published date', val.publishedDate);
              const startingDate = new Date(val.publishedDate);
              this.PublishedDatenew = startingDate.toString().slice(4, 15);
              console.log('@@@ startingDate after convert to date', this.PublishedDatenew);

              this.careblogposttitle = this.htmlDecode(val.contentNodes.Title.value);
              console.log('@@@ careblogpost title:', this.careblogposttitle);

              this.careblogpostimage = this.imgUrl + val.contentNodes.Image.url;
              //this.careblogpostimage = val.contentNodes.Image.url;
              console.log('@@@ careblogpost image:', this.careblogpostimage);

              var body = this.htmlDecode(val.contentNodes.Body.value);
              /* body = body.replaceAll('&lt;', '');
              body = body.replaceAll('/p&gt;', '');
              body = body.replaceAll('p&gt;', '');
              body = body.replaceAll('&amp;', '');
              body = body.replaceAll('br&gt;', '');
              body = body.replaceAll('nbsp;', ' ');
              body = body.replaceAll('h3&gt;', '');
              //body = body.replaceAll('&#39;','\'');
              console.log('@@@ careblogpost body:', body);
              var careblogpostbody = body.split('/');
              console.log('@@@ careblogpost body after split:', careblogpostbody);

              console.log('@@@ careblogpost body length: ', careblogpostbody.length);
              var careblogpostarray = [];
              var storeobj = '';
              for (var i = 0; i < careblogpostbody.length; i++) {
                storeobj = careblogpostbody[i];
                console.log('@@@ storeobj value', storeobj);
                careblogpostarray.push(storeobj);
              } */
              this.bodycareblogpost = body;
              console.log('@@@ careblogpostbody Value:', this.bodycareblogpost);

            }

            this.getScreenSize();
          }

        }

      }
      this.spin = false;
    }).catch(err => {
      this.spin = false;
    })
  }

  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }
}