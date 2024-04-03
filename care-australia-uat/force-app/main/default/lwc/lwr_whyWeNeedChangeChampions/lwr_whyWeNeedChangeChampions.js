import { LightningElement, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import LWCConfigSettingMetadata from '@salesforce/apex/LWC_AllLoansCtrl.LWCConfigSettingMetadata';
import basePath from '@salesforce/community/basePath';

export default class Lwr_whyWeNeedChangeChampions extends LightningElement {
    ntitles;
    whyweneedBody;
    val1;
    val2;
    imgUrl = basePath + '/sfsites/c';

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }

    @wire(LWCSectionMetaData, { category: 'becomechangechampionpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire becomechangechampion page 2nd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Why we need Change Champions") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Why we need in val1:', this.val1); 
            console.log('@@@ Change Champion in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
    }

    @wire(LWCConfigSettingMetadata)
    wiredCustomMetadataRecords({ data, error }) {
        if (data) {
            console.log('@@@ enter into wire');
            console.log('@@@currencyvalue', data.Change_Champion_Currencies__c);
            var curr = data.Change_Champion_Currencies__c;
            console.log('@@@currvalue', curr);
            this.currsplit = curr.split(',');
            console.log('@@@ Currency after split :', this.currsplit);


            //var arraa= data.value.Change_Champion_Currencies__c	;
            //console.log('@@@currencyvalue', data);

            //this.customMetadataRecords = data;
            //console.log('@@@currencyvalue', data);
        } else if (error) {
            // Handle error
        }
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }

    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    sectionName = 'Why LWC';
    getCMSContent() {

        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {
                        if (val.contentNodes.Tag.value == 'WhyWeNeed') {
                            /*var title1 = val.contentNodes.Title.value;
                            console.log('@@@ Title1 part :', title1);
                            if (title1 != undefined) {
                                var ntitles = title1.split(' ');
                                //var titleContent = '';
                                console.log('@@@ Title1 after split :', ntitles);
                                var a = [];
                                var obj = {};
                                var bk = '';
                                var yl = '';
                                for (var i = 0; i < ntitles.length; i++) {
                                    if (i == 0 || i <= 2) {
                                        bk += ntitles[i] + " ";
                                        console.log('white title: ', bk);
                                        obj.white = bk;
                                    } else {
                                        yl += ntitles[i] + " ";
                                        console.log('yellow title: ', yl);
                                        obj.yellow = yl;
                                    }
                                }
                                a.push(obj);
                                obj = {};
                                console.log('@@@ Title1 Value:', a);
                                this.ntitles = a;
                            }*/
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                           /*  var body = val.contentNodes.Body.value;
                            console.log('@@@ body1 part:', body);
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
                            this.whyweneedBody = body;
                            console.log('@@@ why we need Body: ', this.whyweneedBody);

                            this.whyweneedimage = this.imgUrl+val.contentNodes.Image.url;
                            console.log('@@@ why we need image part :', this.whyweneedimage);

                        }
                    }
                }
            
            }}).catch(e => {
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })
        
    }
}