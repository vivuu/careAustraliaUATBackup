import { LightningElement, track, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class CareHomePage_byTheNumber extends LightningElement {
    @track screenWidth;
    @track screenHeight;


    descriptions = [];
    sectionName = 'Why LWC';
    val1;
    val2;
    @wire(LWCSectionMetaData, { category: 'homepage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for by the numbers');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "ByTheNumbers") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ by the in val1:', this.val1);
            console.log('@@@ numbers in val2:', this.val2);

        } else if (error) {
            // Handle error
        }
    }
    connectedCallback() {
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;
    
        return parsedstring;
    }

    getCMSContent() {
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined &&
                        val.contentNodes.Tag.value == 'Bythenumbers') {
                        var body = this.htmlDecode(val.contentNodes.Body.value);
                        //body = this.htmlDecode(body);
                       /* body = body.replaceAll('&lt;', '');
                        body = body.replaceAll('/p&gt;', '');
                        body = body.replaceAll('p&gt;', '');*/
                        console.log('@@@careHomepage-By the numbers Body:', body);
                        if (val.contentNodes.Tag.value == 'Bythenumbers') {
                            i++;
                            console.log('-->', val);
                            if (val.contentNodes.Tag != undefined) {
                                var obj = { 'title': val.title, 'body': body, 'idx': parseInt(val.contentNodes.SortOrder.value) };
                                arr.push(obj);
                            }
                        }
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
                    this.descriptions = arr;
                    console.log('@@@careHomepage-By the numbers', this.descriptions);
                }
            }
        }).catch(e => {
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })
    }


    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
}