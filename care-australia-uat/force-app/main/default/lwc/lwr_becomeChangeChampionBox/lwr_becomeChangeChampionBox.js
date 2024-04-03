import { LightningElement, api, wire,track } from 'lwc';
import getContent from '@salesforce/apex/CareHomePageCtrl.getContent';
import getMinOtherCurrency from '@salesforce/apex/LWC_AllLoansCtrl.getMinOtherCurrency';
import LWCConfigSettingMetadata from '@salesforce/apex/LWC_AllLoansCtrl.LWCConfigSettingMetadata';
import { publish,createMessageContext, subscribe } from 'lightning/messageService';
import CARTMC from "@salesforce/messageChannel/CartMessageChannel__c";
export default class Lwr_becomeChangeChampionBox extends LightningElement {
    context = createMessageContext();
    boxTitle;
    customMetadataRecords;
    boxButton;
    changeChampionWindowBody;
    currsplit;
    selectedCurr;
    @api innercurrencybg;
    showCurrInput = false;
    showError=false;
    minOtherCurrency;
    //boxarr[];
    CchampionButton = false;
    selectedIndex;
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
   htmlDecode(input) {
        var doc = new DOMParser().parseFromString(input, 'text/html');
        let parsedstring = doc.documentElement.textContent;

        return parsedstring;
    }

    @wire(getMinOtherCurrency)
    wiredCurrency( { data, error } ){
        console.log('WIREC:',data);
        if( data!=undefined ){
            this.minOtherCurrency = data;
        }
    }
    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
    @track selectedCurrency = null;
    rendered = false;
    renderedCallback(){
        if( !this.rendered ){
            console.log('Inside rendered', localStorage.getItem('isCC'), localStorage.getItem('SelectedCCIndex'),localStorage.getItem('SelectedCCAmount'),localStorage.getItem('OtherChecked') );
            if( localStorage.getItem('isCC') != 'undefined' && localStorage.getItem('isCC')!=undefined ){
                var selIdx = localStorage.getItem('SelectedCCIndex');
                var isCC = localStorage.getItem('isCC')!=undefined?localStorage.getItem('isCC')=='false'||localStorage.getItem('isCC')==false?false:localStorage.getItem('isCC'):localStorage.getItem('isCC');
                var selAmt = localStorage.getItem('SelectedCCAmount');
                this.showCurrInput = localStorage.getItem('OtherChecked') == 'true';
                this.CchampionButton = isCC;
                this.selectedCurrency = selAmt;
                this.selectedCurr = selAmt;
                this.selectedIndex = Number(selIdx);
                console.log('Valuess:',this.CchampionButton, this.selectedCurrency, this.selectedIndex);
                if( this.selectedIndex!=undefined ){
                    var ele = this.template.querySelectorAll('.voldonaButtons');
                    for( var e of ele ){
                        e.classList.remove( 'selectedButton' );
                    }
                    console.log('ValuessEle:',JSON.parse(JSON.stringify(ele)));
                    console.log('ValuessEle:',ele.length);
                    console.log('ValuessEle:',this.selectedIndex);
                    if( this.selectedIndex != undefined && ele != undefined ){
                        if( ele.length > this.selectedIndex ){
                            var element = ele[this.selectedIndex];
                            console.log('ValuessElement:',ele);
                            console.log('ValuessElement:',element);
                            console.log('ValuessElement:',JSON.parse(JSON.stringify(element)));
                            console.log('ValuessElement:',JSON.parse(JSON.stringify(ele)));
                            element.classList.add( 'selectedButton' );
                        }
                    }
                }
                var ele = this.template.querySelectorAll('.voldonaButtons');
                if(ele!=undefined && ele.length>0)  this.rendered = true;
            }
        }
    }
    connectedCallback() {
        this.subscribeMC();
        var innerStyle='margin:10px 10px 10px 0px;background-color:'+this.innercurrencybg+';display:inline-flex;border-radius:20px;width:100%';
        this.innercurrencybg= innerStyle;
        this.getScreenSize();
        window.addEventListener('resize', this.getScreenSize.bind(this));
        this.getCMSContent();
        /* console.log('SELVALUESSS:',localStorage.getItem('isCC'),localStorage.getItem('isCC')!='undefined', localStorage.getItem('isCC')!=undefined);
        this.CchampionButton = localStorage.getItem('isCC')!='undefined' && localStorage.getItem('isCC')!=undefined;
        let rdAmt = localStorage.getItem('rdAmt');
        this.selectedCurrency = rdAmt;
        console.log('SelectedVals:',this.CchampionButton, this.selectedCurrency); */
       /*  if (rdAmt != null || rdAmt != undefined) {
            // Get the button that matches the selected currency
            const button = this.template.querySelectorAll(`button[data-curr="${rdAmt}"]`);
            console.log('button value ccb ', button);
            // Highlight the button
            button.classList.add('selected');
        } */
        //this.highlightButton();
    }
    highlightButton() {
    // Get the button that matches the selected currency
    console.log('button highlightButton before ')
    const button = this.template.querySelector(`button[data-curr="${this.selectedCurrency}"]`);
    console.log('button highlightButton ', button)
    // If the button is not null, then highlight it
    if (button !== null) {
      button.classList.add('selected');
    }
  }
    sectionName = 'Why LWC';
    getCMSContent() {

        getContent({ channelName: this.sectionName }).then(res => {
            var r = JSON.parse(res);
            //console.log(r);
            if (r != undefined) {
                var arr = [];
                var i = 1;
                for (var val of r.items) {
                    if (val.type == 'CareAustraliaSite' && val.contentNodes.Tag != undefined) {

                        if (val.contentNodes.Tag.value == 'ChangeChampionWindow') {
                            var boxTitle = val.contentNodes.Title.value;
                            //console.log('@@@ boxTitle part :', boxTitle);
                            if (boxTitle != undefined) {
                                var nboxTitle = boxTitle.split('$');
                                var i = 0;
                                var arr2 = [];
                                for (var val2 of nboxTitle) {
                                    //console.log('OUTPUT : ', val2);
                                    var obj = {};
                                    if (i != 0) {
                                        obj = { 'changeColor': true, 'body': '$' + val2.substring(0, val2.indexOf(' ')) };
                                        var obj2 = { 'changeColor': false, 'body': val2.substring(val2.indexOf(' ')) };
                                        i++;
                                        arr2.push(obj);
                                        arr2.push(obj2);
                                        continue;
                                    } else {
                                        obj = { 'changeColor': false, 'body': val2 };
                                    }
                                    i++;
                                    arr2.push(obj);
                                }
                                //console.log('OBJ:', arr2);
                                this.nboxTitle = arr2;
                                /* 
                                //var titleContent = '';
                                console.log('@@@ nboxtitle after split :', nboxTitle);
                                var a = [];
                                var obj = {};
                                var bk = '';
                                var yl = '';
                                for (var i = 0; i < nboxTitle.length; i++) {
                                    if(i==0){
                                        
                                    }
                                   else if (i == 1 || i == 7) {
                                        yl += nboxTitle[i] + " ";
                                        console.log('yellow title: ', yl);
                                        obj.yellow = yl;
                                    } else {
                                        bk += nboxTitle[i] + " ";
                                        console.log('black title: ', bk);
                                        obj.black = bk;
                                    }
                                }
                                a.push(obj);
                                obj = {};
                                console.log('@@@ nboxtitle Value:', a);
                                this.nboxTitle = a; */
                            }
                            //console.log('@@@ body1 part:', val.contentNodes);
                            var body = this.htmlDecode(this.htmlDecode(val.contentNodes.Body.value));
                            //console.log('@@@ body1 part:', body);
                            /*body = body.replaceAll('&lt;', '');
                            body = body.replaceAll('/p&gt;', '');
                            body = body.replaceAll('p&gt;', '');
                            body = body.replaceAll('&amp;', '');
                            body = body.replaceAll('br&gt;', '');
                            body = body.replaceAll('nbsp;', ' ');
                            body = body.replaceAll('h3&gt;', '');
                            body = body.replaceAll('/h3&gt;', '');
                            body = body.replaceAll('/', '');
                            body = body.replaceAll('&#39;', '\'');*/
                            //this.changeChampionWindowBody = body;
                            //console.log('@@@ ChangeChampionWindow Body: ', this.changeChampionWindowBody);
                            if (body != undefined) {
                                var changeChampionWindowBody = body.split('$');
                                //console.log('@@@change champion body', changeChampionWindowBody)
                                var i = 0;
                                var arr3 = [];
                                for (var val3 of changeChampionWindowBody) {
                                    //console.log('OUTPUT : ', val3);
                                    var obj = {};
                                    if (i != 0) {
                                        obj = { 'changeColor': true, 'body': '$' + val3.substring(0, val3.indexOf(' ')) };
                                        var obj3 = { 'changeColor': false, 'body': val3.substring(val3.indexOf(' ')) };
                                        i++;
                                        arr3.push(obj);
                                        arr3.push(obj3);
                                        continue;
                                    } else {
                                        obj = { 'changeColor': false, 'body': val3 };
                                    }
                                    i++;
                                    arr3.push(obj);
                                }
                                //console.log('OBJ:', arr3);
                                this.changeChampionWindowBody = arr3;

                            }
                            this.boxButton = val.contentNodes.ButtonName.value;
                            //console.log('@@@ ChangeChampionWindow button part :', this.boxButton);

                        }

                    }
                }
            }
        }).catch(e => {
            console.log('OUTPUT : error ', e.toString());
            console.log('OUTPUT : error ', e);
        })
    }
    selectedCurrencyFromBox;
    handleCurrClickEvent( event ){
        var curr = event.target.dataset.curr;
        var idx = event.target.dataset.idx;
        const message = {
            messageToSend: 'BecomeChampionCurrChange',
            currentRecordId:idx,
            amountAddedToCart:curr
        };
        console.log('Publish');
        publish(this.context, CARTMC, message);
        var ele = this.template.querySelectorAll('.voldonaButtons');
        for( var e of ele ){
            e.classList.remove( 'selectedButton' );
        }
        if( idx != undefined && ele != undefined ){
            if( ele.length > idx ){
                var element = ele[idx];
                element.classList.add( 'selectedButton' );
            }
        }
    }
    handleCurrClick( idx, curr ){
        console.log('handleCClick:',curr, idx);
        this.CchampionButton = false;
        /* var curr = event.target.dataset.curr;
        var idx = event.target.dataset.idx; */
        this.showError = false;
        if( curr != undefined ){
            this.selectedIndex=idx;
            if( curr == 'Other' ){
                this.showCurrInput = true;
                this.selectedCurr = 0;
            } else {
                this.showCurrInput = false;
                console.log('SELCUR', curr, curr.replaceAll('$',''));
                this.selectedCurr = parseInt(curr.replaceAll('$',''));
            }
            var selectedEvent = new CustomEvent('btnselected', { detail:        
                {'idx' : idx}});
            this.dispatchEvent(selectedEvent);
        } else{
            this.showCurrInput = false;
        }
        var ele = this.template.querySelectorAll('.voldonaButtons');
        for( var e of ele ){
            e.classList.remove( 'selectedButton' );
        }
        if( idx != undefined && ele != undefined ){
            if( ele.length > idx ){
                var element = ele[idx];
                element.classList.add( 'selectedButton' );
            }
        }
        /* this.CchampionButton = false;
        const selectedButton = event.target;

        // Remove the yellow background from all buttons
        const buttons = this.template.querySelectorAll('.voldonaButtons');
        buttons.forEach(button => {
            button.classList.remove('selected');
        });

        // Add the yellow background to the clicked button
        selectedButton.classList.add('selected');

        
        var cur = event.target.dataset.curr;
        var curr = cur.replaceAll('$','');
        
        var idx = event.target.dataset.idx;
        this.showError = false;
        if( curr != undefined ){
            if( curr == 'Other' ){
                this.showCurrInput = true;
                this.selectedCurr = 0;
                
            } else {
                this.showCurrInput = false;
                this.selectedCurr = curr
                //console.log('this.selectedCurr 206 ',this.selectedCurr)
                
            }
            var selectedEvent = new CustomEvent('btnselected', { detail:        
                {'idx' : idx}});
            this.dispatchEvent(selectedEvent);
        } else{
            this.showCurrInput = false;
        }
        var ele = this.template.querySelectorAll('.voldonaButtons');
        for( var e of ele ){
            e.classList.remove( 'selectedButton' );
        }
        if( idx != undefined && ele != undefined ){
            if( ele.length > idx ){
                var element = ele[idx];
                element.classList.add( 'selectedButton' );
            }
        }
        this.selectedIndex = idx; */
    }
    @api handleBtnSelected( idx ){
        var ele = this.template.querySelectorAll('.voldonaButtons');
        for( var e of ele ){
            e.classList.remove( 'selectedButton' );
        }
        if( idx != undefined && ele != undefined ){
            if( ele.length > idx ){
                var element = ele[idx];
                element.classList.add( 'selectedButton' );
            }
        }
    }
    handleCurrChangeEvent( event ){
        const message = {
            messageToSend: 'BecomeChampionOtherCurrChange',
            currentRecordId:event.target.value
        };
        console.log('Publish');
        publish(this.context, CARTMC, message);
    }
    handleCurrChange( curr ){
        if( curr != undefined && curr != '' && curr >=this.minOtherCurrency){
            curr = parseFloat(curr);
            this.selectedCurr = curr;
            
            this.showError = false;
        }
        else if(curr != undefined && curr != '' && curr < this.minOtherCurrency){
            this.showError = true;
        }
    }
    handleBecomeAChampion(){
        console.log(this.selectedCurr);
        if( this.selectedCurr == undefined || this.selectedCurr== 0 || (this.selectedCurr < this.minOtherCurrency && this.showCurrInput) ){
            console.log('Error if part ');
            this.showError = true;
        } else{
            localStorage.setItem( 'SelectedCCIndex', this.selectedIndex );
            localStorage.setItem( 'isCC', true );
            localStorage.setItem( 'SelectedCCAmount', this.selectedCurr );
            localStorage.setItem('OtherChecked', this.showCurrInput);
            this.showError = false;
            console.log('else part ', this.selectedCurr)
            const amountAsNumber = parseFloat(this.selectedCurr);
            /* const addchangechampiontocart = new CustomEvent('fromchangechampionbox', {
                detail: amountAsNumber
            });

            this.dispatchEvent(addchangechampiontocart); */
            this.CchampionButton = true;
            const message = {
                messageToSend: 'ChangeChampion',
                currentRecordId:amountAsNumber
            };
            publish(this.context, CARTMC, message);
            console.log('VALLL:', localStorage.getItem('isCC'), localStorage.getItem('SelectedCCIndex'),localStorage.getItem('SelectedCCAmount'), localStorage.getItem('OtherChecked'));
        }
    }
    handleBecomeAChampionEvent(){
        const message = {
            messageToSend: 'BecomeChampionAddToCart',
            currentRecordId:true
        };
        console.log('Publish');
        publish(this.context, CARTMC, message);
    }
    subscribeMC() {
        subscribe(this.context, CARTMC, (message) => {
            console.log('SSSUU', message);
            if( message.messageToSend == 'BecomeChampionAddToCart' ){
                console.log('Subs');
                this.handleBecomeAChampion();
            } else if( message.messageToSend == 'BecomeChampionCurrChange' ){
                console.log('MM:',message.messageToSend);
                this.handleCurrClick( message.currentRecordId, message.amountAddedToCart );
            } else if( message.messageToSend == 'BecomeChampionOtherCurrChange' ){
                console.log('MM:',message.messageToSend);
                this.handleCurrChange( message.currentRecordId );
            }
        });
    }
    openCheckout(){
        const message = {
            messageToSend: 'Checkout',
            currentRecordId:true
        };
        publish(this.context, CARTMC, message);
        /* const cart = true;
        const opencart = new CustomEvent('opencart', {
            detail: cart
            });

            this.dispatchEvent(opencart); */
    }
}