import { LightningElement,wire} from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class AboutYourDonationChampion extends LightningElement {


    imgUrl = basePath + '/sfsites/c';
    ntitles1;
    aboutdonationdescriptions;
    val1;
    val2;

    @wire(LWCSectionMetaData, { category: 'becomechangechampionpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire becomechangechampion page 3rd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "About your donation") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ About your in val1:', this.val1); 
            console.log('@@@ donation in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
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
                        if (val.contentNodes.Tag.value == 'AboutYourDonation1') {
                            /*var title2 = val.contentNodes.Title.value;
                            console.log('@@@ Title2 part :', title2);
                            if (title2 != undefined) {
                                var ntitles1 = title2.split(' ');
                                //var titleContent = '';
                                console.log('@@@ Title2 after split :', ntitles1);
                                var a = [];
                                var obj = {};
                                var bk = '';
                                var yl = '';
                                for (var i = 0; i < ntitles1.length; i++) {
                                    if (i == 0 || i <= 1) {
                                        bk += ntitles1[i] + " ";
                                        console.log('white title: ', bk);
                                        obj.white = bk;
                                    } else {
                                        yl += ntitles1[i] + " ";
                                        console.log('yellow title: ', yl);
                                        obj.yellow = yl;
                                    }
                                }
                                a.push(obj);
                                obj = {};
                                console.log('@@@ Title2 Value:', a);
                                this.ntitles1 = a;
                            }*/
                            this.aboutdonationimage = this.imgUrl+val.contentNodes.Image.url;
                            console.log('@@@ about donation image part :', this.aboutdonationimage);

                        }
                        if (val.contentNodes.Tag.value == 'AboutYourDonation') {
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /* var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('h4&gt;', '');
                            body = body.replaceAll('/', '');
                            console.log('Body:', body); */
                            if (val.contentNodes.Tag.value == 'AboutYourDonation') {
                                i++;
                                console.log('-->', val);
                                if (val.contentNodes.Tag != undefined) {
                                    var obj = { 'title': val.title, 'body': body, 'idx': parseInt(val.contentNodes.SortOrder.value) };
                                    arr.push(obj);
                                }
                            }
                            if (arr.length > 0) {
                    arr.sort((a, b) => {
                        return a.idx - b.idx;
                    });
                    for (var i = 0; i < arr.length; i++) {
                        var size = 3;
                        if (i == 0 || (i + 1) % 4 == 0) {
                            size = 2;
                        }
                        arr[i].size = size;
                    }
                    this.aboutdonationdescriptions = arr;
                    console.log('@@@ about donation descriptions', this.aboutdonationdescriptions);
                }

                        }

                    }
                }

            }
        }).catch(e => {
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })

    }
}