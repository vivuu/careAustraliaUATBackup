import { LightningElement, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';

export default class BecomeChangeChampionHeader extends LightningElement {

    spin = false;
    titles;
    desktopimage;
    val1;
    val2;


    imgUrl = basePath + '/sfsites/c';
    @wire(LWCSectionMetaData, { category: 'becomechangechampionpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire becomechangechampion page 1st section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Become a Change Champion") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Become a in val1:', this.val1); 
            console.log('@@@ Change Champion in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
    }

    fromChangeChampionBox(event){
        const val = event.detail;
        //console.log('from box ', val);
        if(val != NaN || val != null || val != undefined){
            const childComponent = this.template.querySelector('c-care-nav-bar');
            //console.log('21',childComponent)
            if (childComponent) {
                childComponent.changeChampionTemplate = true;
                childComponent.callChangeChampionFromParent(val);
                console.log('Setting to true');
                localStorage.setItem('isCC',true);
                //console.log('childcomp end here ')
            }
        }
    }
    openCart(event){
        if (event.detail == true){
            const childComponent = this.template.querySelector('c-care-nav-bar');
            
            if (childComponent) {
                childComponent.carecart = true;
                //childComponent.cartmodules = true;
                localStorage.setItem('isCC',true);
                
            }

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
        this.spin = true;
        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            //console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {

                        if (val.contentNodes.Tag.value == 'ChangeChampionHeader') {
                            this.desktopimage = this.imgUrl+val.contentNodes.Image.url;
                            //console.log('@@@ Header Image part :', this.desktopimage);

                            /*var title = val.contentNodes.Title.value;
                            //console.log('@@@ Title part :', title);
                            if (title != undefined) {
                                var titles = title.split(' ');
                                //var titleContent = '';
                                //console.log('@@@ Title after split :', titles);
                                var a = [];
                                var obj = {};
                                var wh = '';
                                var yl = '';
                                for (var i = 0; i < titles.length; i++) {
                                    if (i == 0 || i == 1) {
                                        wh += titles[i] + " ";
                                        //console.log('white title: ', wh);
                                        obj.white = wh;
                                    } else {
                                        yl += titles[i] + " ";
                                        //console.log('yellow title: ', yl);
                                        obj.yellow = yl;

                                    }
                                }
                                a.push(obj);
                                obj = {};
                                //console.log('@@@ Title Value:', a);
                                this.titles = a;

                            }*/


                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /* var body = val.contentNodes.Body.value;
                            console.log('@@@ body part:', body);
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
                            this.changeChampionHeaderBody = body;
                            //console.log('@@@ change champion body: ', this.changeChampionHeaderBody);

                        }
                    }
                }
            }
            this.spin = false;
        }).catch(e => {
            this.spin = false;
            console.log('OUTPUT :error ', e.toString());
            console.log('OUTPUT :error ', e);
        })

    }
}