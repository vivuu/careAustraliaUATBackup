import { LightningElement,track,wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class Lwr_careContactUsInformation extends LightningElement {
    @track screenWidth;
    @track screenHeight;
    spin = false;
    desktopimage;
    mobileimage;
    contactussection;
    newslettersection;
    loremsection;
    //titles;
    //ntitles;
    imgUrl = basePath + '/sfsites/c';
    carecontactuslabels = [];
    val1;
    val2;

    @wire(LWCSectionMetaData, { category: 'carecontactuspage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire carecontactuspage 3rd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Lendwithcare") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Lendwithcare  in val1:', this.val1); 
            console.log('@@@  in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
    }

    get backgroundImage() {

        this.getScreenSize();
        if (this.screenWidth <= 414 && this.screenHeight <= 915) {
            return this.mobileimage;
            //return ABTMOBbanner;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return this.desktopimage;
            //return AboutUsBanners;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }
    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
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
                        
                        if (val.contentNodes.Tag.value == 'LoremSection') {
                            /* var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('amp;', '&'); */
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            //'title': val.contentNodes.Title.value, 
                            this.loremsection = { 'body': body };
                            console.log('@@@ loremsection :', this.loremsection);
                        }
                        this.getScreenSize();
                    }

                }

            }
            this.spin = false;
        }).catch( err=>{
            this.spin = false;
            console.log('Error:',err);
        } )
    }


    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
}