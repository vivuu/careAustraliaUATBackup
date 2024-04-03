import { LightningElement, wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class Lwr_championWithLendcare extends LightningElement {
    championwithlendcareBody;
    nbottom
    //boxarr[];
    val1;
    val2;

    @wire(LWCSectionMetaData, { category: 'becomechangechampionpage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire becomechangechampion page 4th section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);

            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Change Champion with Lendwithcare") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Become a Change Champion with in val1:', this.val1);
            console.log('@@@ Lendwithcare in val2:', this.val2);

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

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
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
                        if (val.contentNodes.Tag.value == 'bottomLine') {
                            var title4 = val.contentNodes.Title.value;
                            console.log('@@@ Title4 part :', title4);
                            if (title4 != undefined) {
                                this.nbottom = this.htmlDecode(title4);
                                console.log('@@@ Title4 :', this.nbottom);
                            }

                        }

                        if (val.contentNodes.Tag.value == 'ChampionWithLendcare') {
                            /*var title3 = val.contentNodes.Title.value;
                            console.log('@@@ Title3 part :', title3);
                            if (title3 != undefined) {
                                var ntitles2 = title3.split(' ');
                                //var titleContent = '';
                                console.log('@@@ Title3 after split :', ntitles2);
                                var a = [];
                                var obj = {};
                                var bk = '';
                                var yl = '';
                                for (var i = 0; i < ntitles2.length; i++) {
                                    if (i == 0 || i <= 4) {
                                        bk += ntitles2[i] + " ";
                                        console.log('white title: ', bk);
                                        obj.white = bk;
                                    } else {
                                        yl += ntitles2[i] + " ";
                                        console.log('yellow title: ', yl);
                                        obj.yellow = yl;
                                    }
                                }
                                a.push(obj);
                                obj = {};
                                console.log('@@@ Title3 Value:', a);
                                this.ntitles2 = a;
                            }*/

                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /* console.log('@@@ body1 part:', body);
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            //body = body.replaceAll('/h3&gt;', '');
                            body = body.replaceAll('/', '');
                            body = body.replaceAll('&#39;', '\''); */
                            // var bodys = body.split('\n');
                            this.championwithlendcareBody = body;
                            console.log('@@@ Champion With Lendcare Body: ', this.championwithlendcareBody);

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