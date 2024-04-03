import { LightningElement } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';

export default class CareHomePage_testimonialsDev extends LightningElement {
    screenWidth;
    screenHeight;
    BannerTestimonial;
    testi1;
    sectionName = 'Why LWC';
    slides;
    testimoni;
    imgUrl = basePath + '/sfsites/c';
    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
        if( this.BannerTestimonial != undefined && this.testi1 != undefined ){
            if(this.screenWidth <= 700){
                this.testimoni = `background-image: url('${this.testi1}')`;
            }
            else{
                this.testimoni = `background-image: url('${this.BannerTestimonial}')`;//;background-size: cover; background-repeat: no-repeat;Height:550px;
            }
        }
    }
    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getSlidesContent();
    }
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;
    
        return parsedstring;
    }
    getSlidesContent(){
        getContent({channelName:this.sectionName}).then( res=>{
            var r = JSON.parse(res);
            console.log( 'Sides:',r );
            if( r!=undefined ){
                var arr = [];
                for( var val of r.items ){
                    if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined &&
                        ( val.contentNodes.Tag.value == 'Testimonials' || val.contentNodes.Tag.value == 'TestimonialsDesktopBanner' || val.contentNodes.Tag.value == 'TestimonialsMobileBanner' ) ){
                        if( val.contentNodes.Tag.value == 'TestimonialsDesktopBanner' ){
                            this.BannerTestimonial = this.imgUrl+val.contentNodes.Image.url;
                        }else if( val.contentNodes.Tag.value == 'TestimonialsMobileBanner' ){
                            this.testi1 = this.imgUrl+val.contentNodes.Image.url
                        } else{
                            var obj = {};
                            obj.image = val.contentNodes.Image!=undefined ? this.imgUrl+val.contentNodes.Image.url: '';
                            obj.heading = val.contentNodes.Title!=undefined ? val.contentNodes.Title.value.replaceAll('&amp;','&'): '';
                            var body='';
                            if(val.contentNodes.Body !=undefined && val.contentNodes.Body.value != undefined ){
                                body = val.contentNodes.Body.value;
                                body = this.htmlDecode(this.htmlDecode(body));
                               /* body = body.replaceAll('&lt;','');
                                body = body.replaceAll('/p&gt;','');
                                body = body.replaceAll('p&gt;','');*/
                            }
                            obj.idx = val.contentNodes.SortOrder!=undefined ? val.contentNodes.SortOrder.value!=undefined? parseInt(val.contentNodes.SortOrder.value) : 100 : 100;
                            obj.description = body;
                            arr.push( obj );
                        }
                    }
                }
                if( arr.length > 0 ){
                    arr.sort((a, b) => {
                        return a.idx - b.idx;
                    });
                    this.slides = arr;
                } 
                if( this.BannerTestimonial != undefined && this.testi1 != undefined ){
                    if(this.screenWidth <= 700){
                        this.testimoni = `background-image: url('${this.testi1}')`; //;background-size: cover; background-repeat: no-repeat;Height:825px;
                    }
                    else{
                        this.testimoni = `background-image: url('${this.BannerTestimonial}')`; //;background-size: cover; background-repeat: no-repeat;Height:550px;
                    }
                }
                console.log('Testimonials:',arr);
            }
        })
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
    }
}