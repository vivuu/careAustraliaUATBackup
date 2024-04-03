import { LightningElement,track,wire } from 'lwc';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import LendWithCareJSCss from '@salesforce/resourceUrl/LendWithCareJSCss';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import LWCSectionMetaData from '@salesforce/apex/CareHomePageCtrl.LWCSectionMetaData';
import basePath from '@salesforce/community/basePath';
import imgMobilenewUpdates from '@salesforce/resourceUrl/NewsUpdatesMobile';


export default class CareAboutUs extends LightningElement {
    
    categories=['All','Climate Adaptation','Climate Mitigation','Women-Led Businesses', 'Increasing Women\'s Employment','Disaster Preparedness or Response'];
    @track screenWidth;
    @track screenHeight;
    spin = false;
    desktopimage;
    mobileimage;
    newsAndUpdatesBody;
    //mobileimage = imgMobilenewUpdates;
    blogpostUrl;
    imgUrl = basePath + '/sfsites/c';
    //htitle;
    itembox1 = [];
    filteredRecords=[];
    categoryType='All';
    isFilter = false;
    NoOfLoans = 0;
    noRecords = false;
    sortOrder = 'Oldest';
    //itembox2 = [];
    //itembox3 = [];
    val1;
    val2;

    get desktopimageBack() {

        this.getScreenSize();
        if (this.screenWidth <= 600) {
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
    @wire(LWCSectionMetaData, { category: 'newsandupdatespage' })
    wiredCustomSectionMetaDataRecords({ data, error }) {
        if (data && data.length > 0) {
            console.log('@@@ Inside wire newsandupdatespage');
            console.log('@@@length:', data.length);
            console.log('@@@ data :', data);
 
            for (let i = 0; i < data.length; i++) {
                if (data[i].MasterLabel == "News & Updates") {
                    this.val1 = data[i].Value_1__c;
                    this.val2 = data[i].Value_2__c;
                }
            }
            console.log('@@@ News & Updates  in val1:', this.val1); 
            console.log('@@@ in val2:', this.val2); 

        } else if (error) {
            // Handle error
        }
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }

    connectedCallback() {
        /* Promise.all([
            loadStyle(this, LendWithCareJSCss + '/bootstrap.min.css'),
            loadStyle(this, LendWithCareJSCss + '/css2.css'),
            loadStyle(this, LendWithCareJSCss + '/slick.css'),
            loadStyle(this, LendWithCareJSCss + '/slick-theme.css'),
        ])
            .then(() => {
                Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-1.11.0.min.js')]).then(() => {
                    Promise.all([loadScript(this, LendWithCareJSCss + '/jquery-migrate-1.2.1.min.js')]).then(() => {
                        Promise.all([loadScript(this, LendWithCareJSCss + '/bootstrap.bundle.min.js')]).then(() => {
                            Promise.all([loadScript(this, LendWithCareJSCss + '/slick.min.js')]).then(() => {
                                console.log("All scripts and CSS are loaded. perform any initialization function.");
                            });
                        });
                    });
                });
            })
            .catch(error => {
                console.log("failed to load the scripts:", error);
            }); */
        this.getScreenSize();
        var bUrl = window.location.href;
        bUrl = bUrl!= undefined? bUrl.substring(0,bUrl.lastIndexOf('/')) : '';
        this.blogpostUrl = bUrl;
        console.log('@@@ blogpostUrl', this.blogpostUrl);
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
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {

                        if (val.contentNodes.Tag.value == 'OurImpact-NewsAndUpdatesmobile'){
                            console.log('@@@ tag value is:',val.contentNodes.Tag.value );
                            this.mobileimage = this.imgUrl + val.contentNodes.Image.url;
                            console.log('@@@ Header Image part :', this.mobileimage);
                        }

                        if (val.contentNodes.Tag.value == 'OurImpact-NewsAndUpdatesHeader') {

                            console.log('@@@ tag value is:',val.contentNodes.Tag.value );
                            this.desktopimage = this.imgUrl + val.contentNodes.Image.url;
                            console.log('@@@ Header Image part :', this.desktopimage);

                            /*var title = val.contentNodes.Title.value;
                            console.log('@@@ Title part :', title);
                            title = title.replaceAll('amp;', '');
                            this.htitle = title;
                            console.log('@@@ Title part :', this.htitle);*/

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
                            var body = val.contentNodes.Body.value;
                            body = this.htmlDecode(body);
                            this.newsAndUpdatesBody = body;
                            console.log('@@@ change champion body: ', this.newsAndUpdatesBody);
                        }

                        if (val.contentNodes.Tag.value == 'Ourimpact') {
                            var location  = val.contentNodes.Location!=undefined?val.contentNodes.Location.value:'';
                            var body = val.contentNodes.Body.value;
                            body = this.htmlDecode(body);
                            console.log('-->',val);
                            var contentkeyvalue = val.contentKey;
                            var imgBlog = '';
                            if (val.contentNodes.Image != undefined){
                                imgBlog = val.contentNodes.Image.url;
                            }
                            var linkValue = '';
                            if( val.contentNodes.Link!=undefined ){
                                console.log('-->',val.contentNodes.Link);
                                linkValue=val.contentNodes.Link.value;
                            }
                            body = body.length >120 ? body.substring(0,120)+'...' : body;
                            var pubDate = val.publishedDate != undefined? new Date(val.publishedDate) : new Date();
                            var cat = val.contentNodes.Category!=undefined?val.contentNodes.Category.value:'';
                            var idx = val.contentNodes.SortOrder!=undefined?val.contentNodes.SortOrder.value:100;  
                            var title = this.htmlDecode(val.title);
                            title = title!=undefined && title.length>35 ? title.substring(0,35)+'...' : title;
                            /* var location = val.contentNodes.Location!=undefined?val.contentNodes.Location.value:'';

                            var title = val.contentNodes.Title.value;
                            console.log('@@@ Title part :', title);
                            title = title.replaceAll('&amp;', '&');

                            var body = val.contentNodes.Body.value;
                            body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            console.log('Body:', body);
                            var newsupdatebody = body.split('/');
                            console.log('@@@ ourimpactbody body after split:', newsupdatebody);
                            console.log('@@@ ourimpactbody body length: ', newsupdatebody.length);
                            var storeobj = '';
                            for (let j = 0; j < 1; j++) {
                                storeobj = storeobj + newsupdatebody[j];
                            }
                            var contentkeyvalue = val.contentKey;
                            var linkValue = '';
                            var btnName = val.contentNodes.ButtonName!=undefined?val.contentNodes.ButtonName.value:'';
                            if( val.contentNodes.Link!=undefined ){
                                linkValue =val.contentNodes.Link.value;
                            }
                            var img = val.contentNodes.Image!=undefined ? this.imgUrl + val.contentNodes.Image.url : '';
                            var idx = val.contentNodes.SortOrder!=undefined?val.contentNodes.SortOrder.value:100;                       
                            var cat = val.contentNodes.Category!=undefined?val.contentNodes.Category.value:'';                       
                            storeobj = storeobj.length >120 ? storeobj.substring(0,120)+'...' : storeobj;
                            console.log('DATEEE:',val.publishedDate);
                            var pubDate = val.publishedDate != undefined? new Date(val.publishedDate) : new Date(); */
                            
                            
                            var obj = { 'title': title, 'body': body, 'img': this.imgUrl+imgBlog, 'pubDate':pubDate,
                            'idx': parseInt(idx), 'button': val.contentNodes.ButtonName.value, 'category':cat,
                            'buttonlink':this.blogpostUrl +linkValue+ '?contentKey='+btoa(contentkeyvalue), 'location': location };
                            //this.itembox1 = obj;
                            arr.push(obj);
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
                    this.itembox1 = arr;
                    this.filteredRecords = this.itembox1;
                    this.NoOfLoans = this.filteredRecords.length;
                    if( this.NoOfLoans == 0 ){
                        this.noRecords = true;
                    }else{
                        this.noRecords = false;
                    }
                    console.log('carousel Items-->' + JSON.stringify(this.itembox1));
                }
            }
            this.spin = false;
        }).catch(e => {
            this.spin = false;
            console.log('OUTPUT : ', e.toString());
            console.log('OUTPUT : ', e);
        })
    }
    handleSort(){
        console.log(this.itembox1);
        var arr = this.filteredRecords.slice(0);
        if( this.sortOrder == 'Oldest' ){
            if (arr.length > 0) {
                arr.sort((a, b) => {
                    return a.pubDate - b.pubDate;
                });
                this.filteredRecords = arr;
                console.log('carousel Items-->' + JSON.stringify(this.itembox1));
            }
            this.sortOrder = 'Newest';
        } else if( this.sortOrder == 'Newest' ){
            if (arr.length > 0) {
                arr.sort((a, b) => {
                    return b.pubDate - a.pubDate;
                });
                this.filteredRecords = arr;
                console.log('carousel Items-->' + JSON.stringify(this.itembox1));
            }
            this.sortOrder = 'Oldest';
        }
    }
    openFilter(){
        this.isFilter = true;
    }
    closeFilterMenu(){
        this.isFilter=false;
    }
    resetFilter(){
        this.categoryType = 'All';
        this.filteredRecords = this.itembox1;
        this.NoOfLoans = this.filteredRecords.length;
        if( this.NoOfLoans == 0 ){
            this.noRecords = true;
        }else{
            this.noRecords = false;
        }
        const buttons = this.template.querySelectorAll('.catogory');
        buttons.forEach(button => {
            if(button.name == 'All'){
                button.classList.add('selected');
            }else{
                button.classList.remove('selected');
            }
        });
    }
    handleButtonClick(event) {
        const selectedButton = event.target;

        // Remove the yellow background from all buttons
        const buttons = this.template.querySelectorAll('.catogory');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });

        // Add the yellow background to the clicked button
        selectedButton.classList.add('selected');
        this.selectedCategory  = event.target.name;

        // Set the selected category
        //this.selectedLoanType = selectedValue;

        if (this.selectedCategory != null && this.selectedCategory == 'All') {
            this.filteredRecords = this.itembox1.slice(0);
            this.NoOfLoans = this.filteredRecords.length;
            if( this.NoOfLoans == 0 ){
                this.noRecords = true;
            }else{
                this.noRecords = false;
            }
            this.categoryType = 'All';
        } else {
            this.categories.forEach(loanRecord => {
                if (this.selectedCategory != null && this.selectedCategory == loanRecord) {
                    this.categoryType = loanRecord;
                }
            });
            var arr = [];
            for( var val of this.itembox1 ){
                if( val.category == this.categoryType ){
                    arr.push( val );
                }
            }
            this.filteredRecords = arr;
            this.NoOfLoans = this.filteredRecords.length;
            if( this.NoOfLoans == 0 ){
                this.noRecords = true;
            }else{
                this.noRecords = false;
            }
        }
    }
    getFilteredLoans(){
        this.isFilter=false;
    }
}