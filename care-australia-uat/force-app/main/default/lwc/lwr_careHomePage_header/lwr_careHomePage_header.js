import { LightningElement } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';
export default class Lwr_careHomePage_header extends LightningElement {
    allLoansUrl;
    screenWidth;
    screenHeight;
    BnGrid1
    BnGrid2
    BnGrid3
    BnGrid4
    spin = false;
    image1;
    image2;
    image3;
    image4;
    image5;
    image6;
    image7;
    image8;
    image9;
    image10;
    image11;
    image12;
    image13;
    image14;
    MobileBannerPng;
    header;
    titles;
    //AniBan;
    imgUrl = basePath + '/sfsites/c';

    get backgroundImage() {
        this.getScreenSize();
        if(this.screenWidth <= 600){
            return `background: transparent linear-gradient(238deg, #E4761E 0%, #FEBE10 100%) 0% 0%;background-size: cover; background-repeat: no-repeat;Height:780px;`;
        }
        else{
            return `background: transparent linear-gradient(238deg, #E4761E 0%, #FEBE10 100%) 0% 0%;background-size: cover; background-repeat: no-repeat;Height:525px;`;
        }
    }
    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
    fromNavBar(event){
        console.log('from navbar ', event.detail);
        if(event.detail == true){
          document.body.style.overflow = 'auto';
        }
        else if(event.detail == false){
          document.body.style.overflow = 'hidden';
        }
    }
    connectedCallback(){
        this.startAnimation();

        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    sectionName = 'Why LWC';
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;
    
        return parsedstring;
    }
    getCMSContent(){
        this.spin = true;
        getContent({channelName:this.sectionName}).then( res=>{
            var r = JSON.parse(res);
            console.log( 'getCMSContent ',JSON.stringify(r) );
            this.spin = false;
            if( r!=undefined ){
                for( var val of r.items ){
                    if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined){
                        console.log('Tag'+val.contentNodes.Tag.value);
                        if(val.contentNodes.Tag.value == 'HomeHeader'){
                            var body = val.contentNodes.Body.value;
                            body = this.htmlDecode(body);
                            console.log('bbb:',body);
                            /* body = body.replaceAll('&lt;','');
                            body = body.replaceAll('/p&gt;','');
                            body = body.replaceAll('p&gt;','');
                            body = body.replaceAll('&amp;','');
                            body = body.replaceAll('br&gt;','');
                            body = body.replaceAll('nbsp;',' '); */
                            //var bUrl = window.location.href;
                            var bUrl = location.href;
                            console.log('bUrl-->'+bUrl);
                            bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
                            console.log('val.contentNodes.Link.value-->'+val.contentNodes.Link.value);
                            this.allLoansUrl = bUrl+val.contentNodes.Link.value;
                            console.log('this.allLoansUrl--->'+this.allLoansUrl);

                            this.header = {'body':body, 'btn':val.contentNodes.ButtonName.value};
                            // this.AniBan = this.imgUrl+val.contentNodes.Image.url;
                            console.log('@@@ Header Body: ',this.header);
                                var title = val.contentNodes.Title.value;
                                if( title!=undefined ){
                                    var titles = title.split(' ');
                                    var titleContent = '';
                                    console.log('title:',val.contentNodes.Title.value);
                                    var a = [];
                                    var obj = {};
                                    for( var i=0; i<titles.length; i++ ){
                                        if( i == 0 || i%2 == 0 ){
                                            obj.white = titles[i];
                                        } else{
                                            obj.violet = titles[i];
                                            a.push( obj );
                                            obj={};
                                        }
                                    }
                                    console.log('A:',a);
                                    this.titles = a;
                                }
                        } else if( val.contentNodes.Tag.value == 'HomeHeader-Mobile' ){
                            this.MobileBannerPng = this.imgUrl+val.contentNodes.Image.url;
                        } else if( val.contentNodes.Tag.value == 'HomePage-BannerGrid' ){
                            var title = val.contentNodes.Title.value;
                            var img = this.imgUrl+val.contentNodes.Image.url;
                            if( title == 'BannerGrid1' ){
                                this.BnGrid1 = img;
                            } else if( title == 'BannerGrid2' ){
                                this.BnGrid2 = img;
                            } else if( title == 'BannerGrid3' ){
                                this.BnGrid3 = img;
                            } else if( title == 'BannerGrid4' ){
                                this.BnGrid4 = img;
                            }
                        } else if( val.contentNodes.Tag.value == 'AnimatedImage' ){
                            if(val.contentNodes.SortOrder!=undefined && val.contentNodes.SortOrder.value != undefined){
                                var idx = parseInt(val.contentNodes.SortOrder.value);
                                var img = this.imgUrl+val.contentNodes.Image.url;
                                console.log('this.imgUrl--->'+this.imgUrl+'--> '+val.contentNodes.Image.url);
                                if( idx == 1 ){
                                    this.image1 = img;
                                    this.image10 = img;
                                } else if( idx == 2 ){
                                    this.image2 = img;
                                    this.image11 = img;
                                } else if( idx == 3 ){
                                    this.image3 = img;
                                    this.image12 = img;
                                } else if( idx == 4 ){
                                    this.image4 = img;
                                    this.image13 = img;
                                } else if( idx == 5 ){
                                    this.image5 = img;
                                    this.image14 = img;
                                } else if( idx == 6 ){
                                    this.image6 = img;
                                } else if( idx == 7 ){
                                    this.image7 = img;
                                } else if( idx == 8 ){
                                    this.image8 = img;
                                } else if( idx == 9 ){
                                    this.image9 = img;
                                }
                            }
                        }
                    }
                        
                }
                
            }
        })
    }
    startAnimation() {
        setInterval(() => {
            this.updateImageStyles();
        }, 2000); 
    }
    updateImageStyles() {
        const images = [
            this.template.querySelector('.Image1'),
            this.template.querySelector('.Image2'),
            this.template.querySelector('.Image3'),
            this.template.querySelector('.Image4'),
            this.template.querySelector('.Image5'),
            this.template.querySelector('.Image6'),
            this.template.querySelector('.Image7'),
            this.template.querySelector('.Image8'),
            this.template.querySelector('.Image9'),
            this.template.querySelector('.Image10'),
            this.template.querySelector('.Image11'),
            this.template.querySelector('.Image12'),
            this.template.querySelector('.Image13'),
            this.template.querySelector('.Image14'),
        ];

        images.forEach((image) => {
            const x = Math.random() * 100;
            const y = Math.random() * 100;
            if(image!=undefined && image.style!=undefined)
            image.style.transform = `translate(${x}vw, ${y}vh)`;
        });
    }
    disconnectedCallback(){
        window.removeEventListener('resize', this.getScreenSize);
    }
    openViewAllloans(){
        //const currentPageUrl =document.URL;
        // window.location.href = this.allLoansUrl;
        location.href = this.allLoansUrl;
    }
}