import { LightningElement,track, api } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';
import TermsandConditions from '@salesforce/resourceUrl/TermsandConditionsFile';

export default class CareHomePage_careFooterDev extends LightningElement {
    lendLogo; //LendWithCareImages+'/logo.png';
    socialMediaIcons=[];
    footerDes;
    copyright;
    footerItems;
    showCmp = false;
    descriptions = [];
    sectionName = 'Why LWC';
    btn;
    imgUrl = basePath + '/sfsites/c';
    TermsandConditionsFile = TermsandConditions;

  connectedCallback() {
    this.getCMSContent();
  }
  htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }
  getCMSContent(){
    try{

      getContent({channelName:this.sectionName}).then( res=>{
          var r = JSON.parse(res);
          //console.log( r );
          if( r!=undefined ){
            var socialMediaArr = [];
            for( var val of r.items ){
                if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined ){
                    if( val.contentNodes.Tag.value == 'Footer-socialmedia' ){
                        var idx = parseInt(val.contentNodes.SortOrder.value);
                        var showSpan = false;
                        //console.log('IDS:',idx);
                        var st = '--color: #ffffff; --background-color: transparent;width: 25px;';
                        if( idx >1 && idx<4 ){
                            showSpan = true;
                            st+='margin-left:10px;'
                        }
                        if( idx == 4 )  st+='margin-left:15px;';
                        var obj = {'title':val.contentNodes.Title.value, 'style':st, 'showSpan':showSpan,'img':this.imgUrl+val.contentNodes.Image.url, 'idx':idx,'link':val.contentNodes.Link.value!=undefined ?val.contentNodes.Link.value:''};
                        socialMediaArr.push(obj);
                    } else if( val.contentNodes.Tag.value == 'Footer-description' ){
                        var body = val.contentNodes.Body.value;
                        body = body.replaceAll('&lt;','');
                        body = body.replaceAll('/p&gt;','');
                        body = body.replaceAll('p&gt;','');
                        body = body.replaceAll('&amp;','');
                        body = body.replaceAll('nbsp;',' ');
                        body = body.replaceAll('br&gt;','');
                        this.footerDes = {'title':val.contentNodes.Title.value, 'img':this.imgUrl+val.contentNodes.Image.url, 'body':body};
                        //console.log('Footer Des : ',this.footerDes);
                    } else if( val.contentNodes.Tag.value == 'Footer-copyright' ){
                        var body = val.contentNodes.Body.value;
                        body = body.replaceAll('&lt;','');
                        body = body.replaceAll('/p&gt;','');
                        body = body.replaceAll('p&gt;','');
                        body = body.replaceAll('&amp;','');
                        body = body.replaceAll('nbsp;',' ');
                        var b = body.substring( 0, body.indexOf('&#92;') );
                        var cont = body.substring( b.length+6 );
                        this.copyright = {'title':val.contentNodes.Title.value, 'img':this.imgUrl+val.contentNodes.Image.url, 'body':b, 'resv':cont, 'link':val.contentNodes.Link!=undefined?val.contentNodes.Link.value:''};
                    } else if( val.contentNodes.Tag.value == 'Footer-Items' ){
                        var body = val.contentNodes.Body.value;
                        this.lendLogo = this.imgUrl+val.contentNodes.Image.url;
                        body = body.replaceAll('&lt;','<');
                        body = body.replaceAll('&quot;','"');
                        body = body.replaceAll('&gt;','>');
                        body = body.replaceAll('<p>','');
                        body = body.replaceAll('</p>','');
                        body = body.replaceAll('&amp;','&');
                        //console.log('FooterBody:',body);
                        body = body.replaceAll('target="_blank"','');
                        body = body.replaceAll( '<a', '<a style="color:white;margin-bottom:12px;text-decoration: none;font-size:12px;line-height:12px;font-family:\'Helvetica Neue Bold Pro\';"' );
                        //console.log('FooterItems:',body);
                        var arr = body.split( '</a>' );
                        //console.log('arr:',arr);
                        var fItemSize = (arr.length - 1)/2;
                        fItemSize = Math.round(fItemSize);
                        //console.log('ItemSize:',fItemSize);
                        body = '';
                        var body2 = '';
                        for( var i = 0; i<fItemSize; i++ ){
                            body+=arr[i]+' </a>';
                        }
                        for( var i = fItemSize; i<arr.length-1; i++ ){
                            body2+=arr[i]+' </a>';
                        }
                        this.footerItems = body;
                        var fItems1 = this.template.querySelectorAll('.fItems1');
                        var fItems2 = this.template.querySelectorAll('.fItems2');
                        if( fItems1!=undefined ){
                            fItems1[0].innerHTML = body;
                            body = body.replaceAll('margin-bottom:12px', 'margin-bottom:10px');
                            body = body.replaceAll('font-size:12px', 'font-size:18px');
                            body = body.replaceAll('line-height:12px', 'line-height:20px');
                            fItems1[1].innerHTML = body;
                        }
                        if( fItems2!=undefined ){
                            fItems2[0].innerHTML = body2;
                            body2 = body2.replaceAll('margin-bottom:12px', 'margin-bottom:10px');
                            body2 = body2.replaceAll('font-size:12px', 'font-size:18px');
                            body2 = body2.replaceAll('line-height:12px', 'line-height:20px');
                            fItems2[1].innerHTML = body2;
                        }
                    }
                }
            }
            if( socialMediaArr.length > 0 ){
                socialMediaArr.sort((a, b) => {
                    return a.idx - b.idx;
                });
                this.socialMediaIcons = socialMediaArr;
                //console.log('SMIcons : ',this.socialMediaIcons);
            }
          }
          this.showCmp = true;
      } ).catch(e=>{
          console.log('OUTPUT : ',e.toString());
          console.log('OUTPUT : ',e);
      })
    }catch( e ){
        console.log('Error:',e);
    }
  }
}