import { LightningElement,track,wire } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';
import isGuestUser from '@salesforce/apex/LWC_AllLoansCtrl.isGuestUser';
import createLead from '@salesforce/apex/LWC_AllLoansCtrl.createLead';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Lwr_careContactUsNewsLetter extends LightningElement {
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
            console.log('@@@ Inside wire carecontactuspage 2nd section');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "Sign up to our newsletter") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ Sign up to  in val1:', this.val1); 
            console.log('@@@ our newsletter in val2:', this.val2); 

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
    handleInputChange(event){
        var label = event.target.dataset.label;
        var val = event.target.value;
        if( label == 'First name' ){
            this.firstName = val;
        } else if( label == 'Last name' ){
            this.lastName = val;
        } else if( label == 'Email' ){
            this.email = val;
        }
    }
    connectedCallback() {
        this.checkGuestUser();
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
    }
    isGuest = false;
    btnDisable = false;
    firstName;
    lastName;
    email;
    checkGuestUser(){
        isGuestUser().then(isGuestUser => {
            this.isGuest = isGuestUser;
            this.btnDisable = !isGuestUser;
            console.log('Guest:',isGuestUser, this.btnDisable);
        });
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
                        
                        if (val.contentNodes.Tag.value == 'NewsletterSection') {
                            console.log('@@body value' + val.contentNodes.Body.value);
                            var body = this.htmlDecode(val.contentNodes.Body.value);
                            /* var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' '); */
                            this.newslettersection = { 'body': body, 'btn': val.contentNodes.ButtonName.value, 'image': this.imgUrl+val.contentNodes.Image.url };
                            console.log('@@@ NewsletterSection Body: ', this.newslettersection);
                            /*var ntitle = val.contentNodes.Title.value;
                            if (ntitle != undefined) {
                                var ntitles = ntitle.split(' ');
                                var ntitleContent = '';

                                console.log('@@@ NewsletterSection Title:', val.contentNodes.Title.value);
                                console.log('@@@ NewsletterSection Title length:', ntitles.length);
                                var a = [];
                                var obj = {};
                                var bk = '';
                                var yk = '';
                                for (var i = 0; i < ntitles.length; i++) {
                                    if (i >= 0 && (i <= 2)) {
                                        bk += ntitles[i] + " ";
                                        console.log('@@@ bk', bk);
                                        obj.black = bk;
                                    } else {
                                        yk += ntitles[i] + " ";
                                        console.log('@@@ yk', yk);
                                        obj.yellow = yk;
                                    }
                                }
                                a.push(obj);
                                obj = {};
                                console.log('@@@ Title Value:', a);
                                this.ntitles = a;
                            }*/
                        }
                        if (val.contentNodes.Tag.value == 'CareContactUsLabels') {
                            var arr = [];
                            var carecontactuslabel = val.contentNodes.Title.value;
                            var idx = parseInt(val.contentNodes.SortOrder.value);
                            arr.push(carecontactuslabel);
                            console.log('@arr:', arr);
                            /*if (arr.length > 0) {
                                arr.sort((a, b) => {
                                    return a.idx - b.idx;
                                });
                            }*/
                            for(let i=0;i<arr.length;i++){
                                this.carecontactuslabels[idx-1]=arr[i];
                            }



                            //this.carecontactuslabels.push(val.contentNodes.Title.value);
                            console.log('@@title values', this.carecontactuslabels);

                            /*this.carecontactuslabels = [{title:'First Name', value:val.contentNodes.Title.value},{title:'Last Name', value:val.contentNodes.Title.value},{title:'Email', value:val.contentNodes.Title.value}];
                            console.log('@@@ carecontactuslabels :', this.carecontactuslabels[0]);*/
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
    showError = false;
    handleSubscribe(){
        if( this.isGuest ){
            this.spin = true;
            console.log('Inside subscribe:',this.firstName, this.lastName, this.email);
            if( this.firstName!=undefined && this.lastName != undefined && this.email!=undefined &&
                this.firstName!='' && this.lastName != '' && this.email!=''
             ){
                this.showError = false;
                createLead({'fName':this.firstName, 'lName':this.lastName, 'Email':this.email}).then( res=>{
                    this.dispatchEvent(new ShowToastEvent
                        ({
                            title: 'Success',
                            message: 'Subscribed!!',
                            variant: 'Success'
                        }));
                    this.spin = false;
                } ).catch( err=>{
                    console.log( err );
                    this.dispatchEvent(new ShowToastEvent
                    ({
                        title: 'Error',
                        message: err,
                        variant: 'error'
                    }));
                    this.spin = false;
                } );
            } else{
                this.showError = true;
                this.spin = false;
            }
        } 
    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
}