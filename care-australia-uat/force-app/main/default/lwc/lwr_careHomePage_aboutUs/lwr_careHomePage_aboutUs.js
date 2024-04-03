import { LightningElement,wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';

export default class Lwr_careHomePage_aboutUs extends LightningElement {
    aboutUsText;
    btn;
    sectionName = 'Why LWC';
    aboutusUrl;
    val1;
    val2;
    connectedCallback(){
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }

    htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }

    @wire(LWCSectionMetaData, {category:'homepage'})
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ enter into wire for About Us');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
            
            for (let i = 0; i < data.length; i++) {
                if(data[i].MasterLabel=="AboutUs"){
                    this.val1= data[i].Value_1__c;
                    this.val2= data[i].Value_2__c;
                }
            }
            console.log('@@@ About  in val1 :',this.val1);
            console.log('@@@ Us in val2:',this.val2);
            
            
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
    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
    getCMSContent(){
        getContent({channelName:this.sectionName}).then( res=>{
            var r = JSON.parse(res);
            console.log( r );
            if( r!=undefined ){
                for( var val of r.items ){
                    if( val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined &&
                        ( val.contentNodes.Tag.value == 'AboutUs' ) ){
                        var body =this.htmlDecode(val.contentNodes.Body.value);
                       /*body = body.replaceAll('&lt;','');
                        body = body.replaceAll('/p&gt;','');
                        body = body.replaceAll('p&gt;','');
                        body = body.replaceAll('br&gt;','');*/
                        this.aboutUsText = body;
                        console.log('AboutUs:', val);
                        // var bUrl = window.location.href;
                        var bUrl = location.href;
                        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
                        var link = val.contentNodes.Link!=undefined?val.contentNodes.Link.value:'';
                        this.aboutusUrl = bUrl+link;
                        console.log('burlll:',bUrl);
                        this.btn = {'label':val.contentNodes.ButtonName.value, 'link':val.contentNodes.Link!=undefined?val.contentNodes.Link.value:''};
                        break;
                    }
                }
            }
            console.log('Button:', this.btn);
        } ).catch(e=>{
            console.log('OUTPUT : ',e.toString());
            console.log('OUTPUT : ',e);
        })
    }
    openAboutLWCpage(){
        console.log('About:',this.aboutusUrl);
        // window.location.href = this.aboutusUrl;
        location.href = this.aboutusUrl;
    }
}