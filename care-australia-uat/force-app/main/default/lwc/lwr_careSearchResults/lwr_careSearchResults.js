import { LightningElement, track, wire } from 'lwc';
import searchLoan from '@salesforce/apex/LWC_AllLoansCtrl.searchLoan';
import basePathName from '@salesforce/community/basePath';

const COLUMNS = [
    { label: 'Title', fieldName: 'Title' },
    { label: 'Description', fieldName: 'Description' },
    { label: 'Type', fieldName: 'Type' },
    // Add more columns as needed
];

export default class Lwr_careSearchResults extends LightningElement {
    searchTerm;
    @track loanResults;
    @track currentId;
    @track data = [];
    @track body = [];
    @track cmsdata = [];
    columns = COLUMNS;
    
    /*columns = [
        { label: 'Loan Type', fieldName: 'Loan_Type__c', type: 'Picklist' },
        { label: 'Loan Title', fieldName: 'Loan_Title__c', type: 'text' }
    ];*/

    getUrlParamValue(url, key){
        return new URL(url).searchParams.get(key);
    }

   /* connectedCallback() {
        const tempId = 'searchTerm';
        this.currentId = this.getUrlParamValue(window.location.href, tempId);
        if (this.currentId) {
            console.log('Test-->'+this.currentId);
            this.searchLoanResults();
        }
    }

    searchLoanResults() {
        console.log('searchLoanResults');
        searchLoan({ searchKey: this.currentId })
            .then(result => {
                this.loanResults = result;
                console.log('Search Results -->',JSON.stringify(this.loanResults));
               // console.log('Search Results Parse -->',typeof(this.loanResults));
                //var parseval = json.s
            })
            .catch(error => {
                console.log(error);
            });
        // Access the search results from the @api property
        
    }*/
     connectedCallback() {
        const tempId = 'searchTerm';
        // this.currentId = this.getUrlParamValue(window.location.href, tempId);
        this.currentId = this.getUrlParamValue(location.href, tempId);
        if (this.currentId) {
            this.searchResults();
        }
    }

    searchResults() {
        searchLoan({ searchKey: this.currentId })
            .then(result => {
                console.log('Result--> from search result '+ JSON.stringify(result));
                this.data = this.mapResults(result);
                this.cmsdata = this.mapCmsResults(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    mapResults(result) {
        const mappedData = [];
        console.log('Result--> from search result result.searchResults '+ JSON.stringify(result.searchResults));
        if (result.searchResults) {
            result.searchResults.forEach(loanRecord => {
                // const currentloanPageUrl = window.location.href;
                const currentloanPageUrl = location.href;
                // const updatedloanUrl = currentloanPageUrl.replace(/s\/[^/]+/, 's/careborrowers?loanId='+btoa(loanRecord.Id)); 
                console.log('path'+basePathName);
                const updatedloanUrl = basePathName+'/careborrowers?loanId='+btoa(loanRecord.Id);
                 
                const mappedLoanRecord = this.mapLoanRecord(loanRecord, updatedloanUrl);
                mappedData.push(mappedLoanRecord);
            });
        }
        console.log('Result--> from search result mappedData '+ JSON.stringify(mappedData));
        return mappedData;
    }

    mapCmsResults(result) {
        const mappedData = [];

        if (result.contentCollection && result.contentCollection.items) {
            result.contentCollection.items.forEach(cmsRecord => {
                if (cmsRecord.contentNodes && cmsRecord.contentNodes.Title && cmsRecord.contentNodes.Title.value) {
                    const titleValueUppercase = cmsRecord.contentNodes.Title.value;
                    if(cmsRecord.contentNodes.Body !== null && cmsRecord.contentNodes.Body !== undefined){
                        if(cmsRecord.contentNodes.Body.value !== null && cmsRecord.contentNodes.Body.value !== undefined){
                            console.log('Inside Replace Entities');
                            this.body = cmsRecord.contentNodes.Body.value;
                            this.body = this.body.replaceAll('&lt;', '');
                            this.body = this.body.replaceAll('&gt;', '');
                            this.body = this.body.replaceAll('/p&gt;', '');
                            this.body = this.body.replaceAll('p&gt;', '');
                            this.body = this.body.replaceAll('&amp;', '');
                            this.body = this.body.replaceAll('br&gt;', '');
                            this.body = this.body.replaceAll('nbsp;', ' ');
                            this.body = this.body.replaceAll('h3&gt;', '');
                            this.body = this.body.replaceAll('&#39;','');
                            this.body = this.body.replaceAll('/','');
                        }
                    }
                    const titleValue = titleValueUppercase.toLowerCase();
                    console.log('titleValue Lowercase-->'+titleValue);
                    if (this.shouldAddCmsRecord(titleValue)) {
                        console.log('Reached-->');
                        const updatedCmsUrl = this.getUpdatedCmsUrl(titleValue);
                        console.log('updatedCmsUrl-->'+updatedCmsUrl);
                        const mappedCmsRecord = this.mapCmsRecord(titleValue, cmsRecord, updatedCmsUrl);
                        console.log('mappedCmsRecord-->'+mappedCmsRecord);
                        mappedData.push(mappedCmsRecord);
                    }
                }
            });
        }

        return mappedData;
    }

    mapLoanRecord(loanRecord, updatedloanUrl) {
        return {
            Id: loanRecord.id,
            LoanTitle: loanRecord.Loan_Title__c,
            LoanDescription: loanRecord.Loan_Description__c,
            LoanType: loanRecord.Loan_Type__c,
            LoanUrl: updatedloanUrl
        };
    }

     shouldAddCmsRecord(titleValue) {
        return (
             (titleValue.indexOf('about us') !== -1 ||
            titleValue.indexOf('change champion') !== -1 ||
            titleValue.indexOf('microfinance') !== -1 ||
            titleValue.indexOf('help centre') !== -1 ||
            titleValue.indexOf('contact us') !== -1) &&
            titleValue.indexOf(this.currentId) !== -1
        );
    }

    getUpdatedCmsUrl(titleValue) {
        // const currentPageUrl = window.location.href;
        const currentPageUrl = location.href;
        console.log('titleValue for mapping-->'+titleValue);
        const pageMapping = {
            'about us': 'aboutus',
            'change champion': 'carebecomechangechampion',
            'become a change champion with lendwithcare': 'carebecomechangechampion',
            'why we need  change champions': 'carebecomechangechampion',
            'become a change champion': 'carebecomechangechampion',
            'our expertise in microfinance': 'aboutmicrofinancing',
            'what is the difference between financial inclusion, microfinance and microcredit?': 'aboutmicrofinancing',
            'when is microfinance not an appropriate tool?': 'aboutmicrofinancing',
            'what kinds of institutions provide microfinance services?': 'aboutmicrofinancing',
            'who is microfinance aimed at?': 'aboutmicrofinancing',
            'about microfinance': 'aboutmicrofinancing',
            'about microfinance-mobile': 'aboutmicrofinancing',
            'contact us': 'carecontactus',
            'help centre': 'carehelpcentre',
            'can i pay via cheque?': 'carehelpcentre',
            'payments & withdrawals': 'carehelpcentre',
            'miscellaneous': 'carehelpcentre',
            'loans and lending': 'carehelpcentre'
        };
        // return currentPageUrl.replace(/s\/[^/]+/, 's/' + pageMapping[titleValue]);
        return basePathName+'/'+pageMapping[titleValue];
    }

    mapCmsRecord(titleValue, cmsRecord, updatedUrl) {
        if(cmsRecord.contentNodes.Body !== null && cmsRecord.contentNodes.Body !== undefined){
            console.log('cameInside');
            if(cmsRecord.contentNodes.Body.value !== null && cmsRecord.contentNodes.Body.value !== undefined){
                console.log('cameInside1');
                return {
                cmsTitle: titleValue,
                cmsDescription: this.body,
                cmsUrl: updatedUrl
                };
            }
        }else{
            return {
                cmsTitle: titleValue,
                cmsDescription: null,
                cmsUrl: updatedUrl
            };
        }
    }
}