import { LightningElement,api,wire } from 'lwc';
import { getRecordCreateDefaults, getRecord } from 'lightning/uiRecordApi';
import getLoanRecordType from '@salesforce/apex/newLoanRecViewController.getRecordTypeId';
import Id from '@salesforce/user/Id';
export default class NewLoanRecViewComp extends LightningElement {

userId=Id;
@api recordId;
@api objectApiName;
@api recTypeId;
uiRecordCreate;
    connectedCallback() {
        console.log('In connected callback');
        const currentPageUrl = window.location.href;
        const parts = currentPageUrl.split('/');
        if (parts.indexOf('loan') >= 0) {
            this.recordId = parts[parts.indexOf('loan') + 1];
            this.objectApiName = 'Loan__c';
        }
        getLoanRecordType({LoanId: this.recordId})
        .then(result => {
            this.recTypeId = result;
            this.error = undefined;
            console.log('Result-->'+this.recTypeId);
        })
        .catch(error => {
            this.error = error;
            this.recordTypeId = undefined;
            console.log('Error-->'+JSON.stringify(this.error));
        });
    }




    activeSections = [];

    @wire(getRecordCreateDefaults, { objectApiName: "Loan__c",recordTypeId: "$recTypeId" })
        propertyOrFunction({ error, data }) {
            if (data) {
                console.log('Data in getRecordCreateDefaults===>:', data);
                this.activeSections = [];
                console.log('Data in uiRecordCreate sections===>:', data.layout.sections);
                let allSectionName = data.layout.sections;
                allSectionName.map(element=>{
                    this.activeSections = [...this.activeSections,element.heading];
                })
                //this.uiRecordCreate = data.layout;
                this.uiRecordCreate = { sections: [] };
                for (let obj of JSON.parse(JSON.stringify(data.layout)).sections) {
                    let section = { ...obj };
                    section.layoutRows = [];
                    for (let obj2 of obj.layoutRows) {
                        let layoutRow = { ...obj2 };
                        layoutRow.layoutItems = [];
                        for (let obj3 of obj2.layoutItems) {
                            let layoutItem = { ...obj3 };
                            layoutItem.layoutComponents = [];
                            for (let obj4 of obj3.layoutComponents) {
                                layoutItem.layoutComponents.push(obj4);
                            }
                            layoutRow.layoutItems.push(layoutItem);
                        }
                        section.layoutRows.push(layoutRow);
                    }
                    this.uiRecordCreate.sections.push(section);
                }
                //console.log('activeSectfieldsions===>:', this.activeSections);
            }
            else if(error){
        console.log('error',JSON.stringify(error));
    }

        }
}