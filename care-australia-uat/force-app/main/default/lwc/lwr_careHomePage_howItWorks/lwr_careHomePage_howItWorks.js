import { LightningElement,track,wire } from 'lwc';
/*import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';*/

import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import basePath from '@salesforce/community/basePath';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import youtubeLink_lwrsite from "@salesforce/label/c.youtubelink_lwrsite";

export default class Lwr_careHomePage_howItWorks extends LightningElement {
    @track screenWidth;
    @track screenHeight;
    //categoryarr;
    allLoansUrl;
    val1;
    val2;
    btn;
    imgUrl = basePath + '/sfsites/c';
    youtubelink=youtubeLink_lwrsite;

    @wire(LWCSectionMetaData, { category: 'homepage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for How it works');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            // var val1 = '';
            // var val2 = '';

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "HowItWorks") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ how it in val1:', this.val1);
            console.log('@@@ works in val2:', this.val2);


            //obj.white = va1;
            //obj.yellow = va2;
            //a.push(obj);
            //obj = {};
            //this.categoryarr = a;

            //var categoryarr = {'value1':data[2].Value_1__c};
            //console.log('@@@ categoryarr :', this.categoryarr);

        } else if (error) {
            // Handle error
        }
    }

    connectedCallback() {
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
            });
            })
            .catch(error => {
                console.log("failed to load the scripts:", error);
            });*/
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    handleProv() {
        // window.location.href = this.btn.link;
        location.href = this.btn.link;
    }
    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }
    descriptions = [];
    sectionName = 'Why LWC';
    getCMSContent() {
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined &&
                        (val.contentNodes.Tag.value == 'HowItWorks-button' || val.contentNodes.Tag.value == 'HowItWorks')) {
                        var body = this.htmlDecode(val.contentNodes.Body.value);

                        if (val.contentNodes.Tag.value == 'HowItWorks-button') {
                            console.log('Button1:', val);
                            // var bUrl = window.location.href;
                            var bUrl = location.href;
                            bUrl = bUrl != undefined ? bUrl.substring(0, bUrl.lastIndexOf('/')) : '';
                            this.allLoansUrl = bUrl + val.contentNodes.Link.value;
                            var oo = { 'title': val.contentNodes.Title.value, 'body': body, 'btnName': val.contentNodes.ButtonName.value, 'link': val.contentNodes.Link.value };
                            this.btn = oo;
                            console.log('Button:', oo);
                        } else if (val.contentNodes.Tag.value == 'HowItWorks') {
                            i++;
                            console.log('-->', val);
                            if (val.contentNodes.Image != undefined) {
                                var order = val.contentNodes.SortOrder != undefined && val.contentNodes.SortOrder.value != undefined ? val.contentNodes.SortOrder.value : 100;
                                var obj = { 'title': val.title, 'body': body, 'img': this.imgUrl + val.contentNodes.Image.url, 'class': 'work-section-meta', 'idx': parseInt(order) };
                                if (val.title == 'They repay') {
                                    obj.style = 'padding-left: 3px; padding-right: 3px;';
                                    obj.class = 'work-section-meta'; /*slds-p-left_large slds-p-right_large*/
                                }
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
    openViewAllloans() {
        console.log(this.allLoansUrl);
        // window.location.href = this.allLoansUrl;
        location.href = this.allLoansUrl;
    }
}