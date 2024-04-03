import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import cartIcon from '@salesforce/resourceUrl/cartIcon';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import Mfpara2 from '@salesforce/resourceUrl/Mfpara2';
import AllLoansHeaderImage from '@salesforce/resourceUrl/AllLoansHeaderImage';
import para4 from '@salesforce/resourceUrl/para4';
import farm from '@salesforce/resourceUrl/farm';
import img5 from '@salesforce/resourceUrl/img5';
import stichingwomen from '@salesforce/resourceUrl/stichingwomen';
import img3 from '@salesforce/resourceUrl/img3';
import MicroFinanceBanner from '@salesforce/resourceUrl/MicroFinanceBanner';
import MicrofinanceMobileBanner from '@salesforce/resourceUrl/MicrofinanceMobileBanner';
import greenfield from '@salesforce/resourceUrl/greenfield';
import loanRecord from '@salesforce/apex/LWC_AllLoansCtrl.getAllLoans_HomePage';
import allLoanRecords from '@salesforce/apex/LWC_AllLoansCtrl.getAllLoans';
import createTransactionRecord from '@salesforce/apex/LWC_AllLoansCtrl.createTransactionRecord';
import getLoanTypes from '@salesforce/apex/LWC_AllLoansCtrl.getLoanTypes';
import LWCConfigSettingMetadata from '@salesforce/apex/LWC_AllLoansCtrl.LWCConfigSettingMetadata';
import getContentDistribution from '@salesforce/apex/LWC_AllLoansCtrl.getContentDistribution';

export default class CareAboutUs extends LightningElement {
    cartIcon = cartIcon;
    @track cart = [];
    canLoadmore = true;
    @api contactid;// = '003AD00000Bs9xdYAB'; //gowsic contact id
    currentPage = 1;
    PAGE_SIZE;
    idsArray = [];
    idsArrayTemp = [];
    @track loanTypes = [];
    selectedLoanType = '';
    buttonvalue = '';
    loanIdsToChild = [];
    loanIdsToCart = [];
    selectedCheckBoxId;
    selectedButtonId;
    selectElement;
    @track screenWidth;
    @track screenHeight;
    isFilter = false;
    isSort = false;
    value = '';
    Loan_Title__c = '';
    loc = '';
    Loan_Type__c = '';
    Loan_Description__c = '';
    Funded__c = '';
    Published_Amount_AUD__c = '';
    objdata = [];
    objdataTemp = [];
    Country__c = '';
    Postcode__c = '';
    FLId = '';
    @track selectedCategory = '';

    @track loanType = null;
    @track businessLocation = null;
    @track sortBy = null;

    wiredAllLoans;

    NoOfLoans = 0;
    NoOfFilteredItems = 0;
    Percentage = 0;
    @track addToCartButton = true;
    @track checkOutButton = false;
    @track disabledButton = false;
    @track selectDisabled = false;
    buttonMessage = 'Add to cart';
    checkout = false;

    lendLogo = LendWithCareImages + '/logo.png';
    Mfpara2 = Mfpara2;
    AllLoansHeaderImage = AllLoansHeaderImage;
    farm = farm;
    para4 = para4;
    img3 = img3;
    img5 = img5;
    stichingwomen = stichingwomen;
    greenfield = greenfield;
    progress;
    $50 = '$50';
    $25 = '$25';
    $10 = '$10';
    $5 = '$5';
    pageData = {};
    pagevalue;
    isFullyFunded = false;
    errorTransaction = false;
    errorMessageOnTransaction = '';
    currentRecordId = [];
    loantypefilter;
    LocationFilter = '';
    @track selectedLocationValue = '';
    TotalNoOfLoans;
    isSorted = false;
    @track amountsFromSettings = [];



    @wire(getLoanTypes)
    wiredLoanTypes({ data, error }) {
        if (data) {
            this.loanTypes = data;
        } else if (error) {
            console.error(error);
        }
    }

    /* get buttonClass() {
         return getButtonClass(this.buttonvalue);
     }
 
     get getButtonClass() {
         return this.selectedCategory === categoryName ? 'category selected' : 'category';
     }*/


    get allTypesClass() {
        return this.selectedCategory === 'All types' ? 'catogory selected' : 'catogory';
    }

    get artHandicraftsClass() {
        return this.selectedCategory === 'Art/Handicrafts' ? 'catogory selected' : 'catogory';
    }

    get cafeRestaurantClass() {
        return this.selectedCategory === 'Cafe/Restaurant' ? 'catogory selected' : 'catogory';
    }

    get garmentfactory() {
        return this.selectedCategory === 'Garment factory' ? 'catogory selected' : 'catogory';
    }

    get farming() {
        return this.selectedCategory === 'Farming' ? 'catogory selected' : 'catogory';
    }

    get educationtraining() {
        return this.selectedCategory === 'Education/training' ? 'catogory selected' : 'catogory';
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
        this.selectedCategory = event.target.name;

        // Set the selected category
        //this.selectedLoanType = selectedValue;

        const clickedButtonId = event.target.getAttribute('data-id');
        console.log('clickedButtonId-->' + clickedButtonId);
        this.selectedButtonId = clickedButtonId;
        console.log('selectedButtonId-->' + this.selectedButtonId);

        if (this.selectedCategory != null && this.selectedCategory == 'All types') {
            this.loanType = null;
            this.LocationFilter = '';
            this.PAGE_SIZE = 9;
            this.objdata = this.objdataTemp;
            this.NoOfLoans = Object.keys(this.objdata).length;
        } else {
            this.loanTypes.forEach(loanRecord => {
                if (this.selectedCategory != null && this.selectedCategory == loanRecord.value) {
                    this.loanType = loanRecord.value;
                    this.PAGE_SIZE = 9;
                }
            });
        }



    }

    fromNavBar(event) {
        console.log('from navbar ', event.detail);
        if (event.detail == true) {
            document.body.style.overflow = 'auto';
        }
        else if (event.detail == false) {
            document.body.style.overflow = 'hidden';
        }
    }

    handleScroll() {
        //console.log('Scroll');
        //console.log('Scroll Started');

        // Get the scroll height, scroll position, and client height
        const scrollHeight = document.documentElement.scrollHeight;
        const scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
        const clientHeight = document.documentElement.clientHeight;

        let value1 = parseInt(scrollHeight) - parseInt(scrollTop);

        // Check if the user has reached the bottom of the page
        this.pagevalue = 1;

        if (value1 === clientHeight) {
            //this.pagevalue = this.pagevalue + 1;
            //this.PAGE_SIZE = this.pagevalue;

            // Apply the CSS class to the element
            this.template.querySelector('.button-line').classList.add('scroll-active');

            //console.log('page_size ', this.PAGE_SIZE);
            //refreshApex(this.wiredAllLoans);
        } else {
            // Remove the CSS class from the element
            this.template.querySelector('.button-line').classList.remove('scroll-active');
        }
        //console.log('ScrollEnd');

    }

    loadMore() {
        this.PAGE_SIZE = this.PAGE_SIZE + 9;
        /*this.businessLocation = this.LocationFilter;
        this.loanType = this.loantypefilter;
        this.idsArray = this.idsArray + this.idsArrayTemp;*/
        //this.NoOfLoans = this.PAGE_SIZE;
        console.log('value from add to cart ', this.PAGE_SIZE);
    }
    timeOut() {
        this.addToCartButton = false;
        this.checkOutButton = true;
        this.disabledButton = false;
        this.selectDisabled = false;
        this.buttonMessage = 'Check Out';
        this.callChildMethod();
    }
    addToCartLoan(event) {

        const selectedAmount = parseInt(this.selectedAmount);
        console.log('this.selectedAmount---onselect', selectedAmount);

        this.disabledButton = true;
        this.selectDisabled = true;

        const itemId = event.currentTarget.dataset.id;
        console.log('Clicked Item ID:', itemId);
        this.loanIdsToCart.add(itemId);
        console.log('Clicked Item IDs :', this.loanIdsToCart);

        setTimeout(() => this.timeOut(), 8000);
        this.Amount_Funded__c = parseInt(this.Amount_Funded__c) + selectedAmount;



        this.selectedAmount = '';
        console.log('this.Amount_Funded__c-->', this.Amount_Funded__c);
        this.amountAddedToCart = this.Amount_Funded__c;
        console.log('this.amountTocart-->', this.amountAddedToCart);

    }

    checkOutToCart() {
        console.log('checkout---->', this.checkout)
        this.checkout = true;
        const childComponent = this.template.querySelector('c-care-nav-bar');
        //console.log('before if (childComponent)')
        if (childComponent) {
            childComponent.openCartPageFromAllLoansPage();
        }

    }
    addToCartFL() {

        if(Number(this.selectedAmount) > 0){
        
        
        const currentRecordItem = this.flRecord[0];
        console.log('currentRecordItem in addToCartFL : ',JSON.stringify(currentRecordItem));
        currentRecordItem.selectedAmount = Number(this.selectedAmount);
        currentRecordItem.Funded = currentRecordItem.Funded__c+Number(this.selectedAmount);
        currentRecordItem.progressBar = (currentRecordItem.Funded / currentRecordItem.Published_Amount_AUD__c) *100;
         currentRecordItem.fundingOptions = this.getFundingOptionsCart((currentRecordItem.Published_Amount_AUD__c -currentRecordItem.Funded), currentRecordItem.selectedAmount)
        currentRecordItem.oldFunded = currentRecordItem.Funded__c;
        console.log('fl loan to apex currentRecordItem ', currentRecordItem);
        this.pageData['Lender__c'] = this.contactid;
        this.pageData['Amount__c'] = currentRecordItem.selectedAmount;
        this.pageData['Type__c'] = 'Loan';
        this.pageData['Loan__c'] = currentRecordItem.Id;

        const currentPageData = [this.pageData];
        console.log('currentPageData : ', JSON.stringify(currentPageData));
        createTransactionRecord({ recordsToInsert: currentPageData })
            .then(result => {
                console.log('createTransactionRecord result 298 : ',JSON.stringify(result));
                currentRecordItem.TransactionId = result[0].Id;
                currentRecordItem.isButtonVisible = true;
                if (result[0].Id.length >= 15 || result[0].Id.length >= 18) {
                    //console.log('currentRecordItem ', currentRecordItem)
                    this.currentRecordId = [...this.currentRecordId, currentRecordItem];
                    const childComponent = this.template.querySelector('c-care-nav-bar');
                    console.log('before if (childComponent) ', this.currentRecordId)
                    if (childComponent) {
                        //console.log('myarray --> ', this.myArray)
                        this.myArray.push(currentRecordItem);

                        // Store the array in local storage
                        localStorage.setItem('myArray', JSON.stringify(this.myArray));
                        childComponent.loanidfromparent = this.currentRecordId;
                        childComponent.timerLoading = true;
                        //childComponent.isTimerStarts = false;
                        childComponent.startTimer1();
                        childComponent.calculateTotalSelectedAmount();
                        childComponent.voluntaryDonation = true;
                        childComponent.createDonationTransRecord();
                        localStorage.setItem('timerLoading',true);
                        localStorage.setItem('isVoluntary', true);
                        this.addToCartButton = false;
                        this.checkOutButton = true;
                        this.disabledButton = true;
                    }
                    this.flRecord[0].Funded__c = this.flRecord[0].Funded__c + this.pageData['Amount__c'];
                    this.Funded__c = this.flRecord[0].Funded__c;
                    this.flRecord[0].progress = (this.flRecord[0].Funded__c / this.flRecord[0].Published_Amount_AUD__c) * 100;
                    this.progress = this.flRecord[0].progress
                    this.flRecord = [...this.flRecord];
                }
            })
            .catch(error => {
                console.log('error from transaction record insert ', error)
                console.log('error from transaction record insert ', JSON.stringify(error))
                console.log('error.body.pageErrors[0].message ', error.body.pageErrors[0].message)
                this.errorTransaction = true;
                this.errorMessageOnTransaction = error.body.pageErrors[0].message;

            })
        this.selectedAmount = 50;
        //console.log('selectedAmount ', this.selectedAmount);
        }
    }
    amountAddedToCart = 0;
    myArray = [];
    addToCart(event) {


        console.log('selectedAmount in addToCart) ',Number(this.selectedAmount));
        if(Number(this.selectedAmount) > 0){

        
        /*this.disabledButton = true;
        this.selectDisabled = true;

        setTimeout(() => this.timeOut(), 8000);*/

        let indexValueForButton = event.target.dataset.id;
        /*console.log('event.detail ',event.detail)*/
        //console.log('event.target.dataset.id ',event.target.dataset.id)
        //console.log('this.objdata[index].Id ',this.objdata[event.target.dataset.id].Id)

        const currentRecordItem = this.objdata[event.target.dataset.id];
        console.log('currentRecordItem in addToCart : ',JSON.stringify(currentRecordItem));
        //currentRecordItem.selectedAmount = Number(this.selectedAmount);
        currentRecordItem.Funded = currentRecordItem.Funded__c+Number(this.selectedAmount);
        currentRecordItem.progressBar = (currentRecordItem.Funded / currentRecordItem.Published_Amount_AUD__c) *100;
        currentRecordItem.fundingOptions = this.getFundingOptionsCart((currentRecordItem.Published_Amount_AUD__c -currentRecordItem.Funded), currentRecordItem.selectedAmount)
        currentRecordItem.oldFunded = currentRecordItem.Funded__c;
        //console.log("type of currentRecordItem ", typeof(currentRecordItem))
        //this.amountAddedToCart = Number(this.amountAddedToCart) + Number(this.selectedAmount);

        this.pageData['Lender__c'] = this.contactid;
        this.pageData['Amount__c'] = currentRecordItem.selectedAmount;
        this.pageData['Type__c'] = 'Loan';
        this.pageData['Loan__c'] = currentRecordItem.Id;


        //console.log('this pagedata to apex ', JSON.stringify(this.pageData))

        const currentPageData = [this.pageData];
        console.log('before apex call ',currentPageData);
        createTransactionRecord({ recordsToInsert: currentPageData })
            .then(result => {
                console.log('result >> ', JSON.stringify(result));
                
                //console.log('currentRecordItem.TransactionId after result ', result[0].Id)
                currentRecordItem.TransactionId = result[0].Id;
                currentRecordItem.isButtonVisible = true;
                //console.log('currentRecordItem.TransactionId after result ', currentRecordItem)
                //console.log('this.currentRecordId ', this.currentRecordId)
                if (result[0].Id.length >= 15 || result[0].Id.length >= 18) {
                    //console.log('currentRecordItem ', currentRecordItem)
                    this.currentRecordId = [...this.currentRecordId, currentRecordItem];
                    /*this.currentRecordId.push(currentRecordItem);
                    if (this.currentRecordId.length > 0 && !this.currentRecordId[0].length) {
                        this.currentRecordId.splice(0, 1); // Remove the element at index 0 if it's empty
                        console.log('after splice ')
                    }*/
                    //console.log('this.currentRecordId after splice  ', this.currentRecordId)
                    //console.log('currentRecordItem after copying ', this.currentRecordId)

                    this.amountAddedToCart = this.amountAddedToCart + 1; //this.currentRecordId.length;

                    /*for (const item of this.currentRecordId) {
                        this.amountAddedToCart += item.selectedAmount;
                    }
                    console.log('before pushing to cart localstorage ', this.cart)
                    this.cart.push(this.currentRecordId);
                    console.log('after pushing to cart localstorage ', this.cart)*/
                    //this.updateLocalStorage();



                    const childComponent = this.template.querySelector('c-care-nav-bar');
                    //console.log('before if (childComponent)')
                    if (childComponent) {
                        //console.log('myarray --> ', this.myArray)
                        this.myArray.push(currentRecordItem);

                        // Store the array in local storage
                        localStorage.setItem('myArray', JSON.stringify(this.myArray));
                        //console.log('after posting to local storage ',localStorage.getItem('myArray') );
                        console.log('this.currentRecordId ',this.currentRecordId );
                        childComponent.loanidfromparent = this.currentRecordId;

                        //console.log('362--> ');
                        //childComponent.loanidfromparent = currentRecordItem;  
                        //childComponent.isTimerStarts = false;      
                        childComponent.startTimer1();
                        childComponent.timerLoading = true;
                        childComponent.calculateTotalSelectedAmount();
                        childComponent.voluntaryDonation = true;
                        //console.log('367')
                        childComponent.createDonationTransRecord();
                        //console.log('369')
                        localStorage.setItem('timerLoading',true);
                        localStorage.setItem('isVoluntary', true);
                        console.log('childComponent.loanidfromparent----> ', JSON.stringify(childComponent.loanidfromparent))
                    }
                    //console.log('after if (childComponent)')
                    //console.log('indexValueForButton ', indexValueForButton)


                    // this will change the button to checkout from addtocart
                    const itemId = this.objdata[indexValueForButton].Id;
                    //console.log('clicked items id --> ', itemId);

                    // Find the clicked item index in the array
                    const itemIndex = this.objdata.findIndex(item => item.Id === itemId);
                    //console.log('itemIndex ', itemIndex);

                    if (itemIndex !== -1) {
                        //console.log('inside if  itemIndex !== -1 ', itemIndex);
                        // Create a copy of the item and update its isButtonVisible property
                        const updatedItem = { ...this.objdata[itemIndex] };
                        updatedItem.isButtonVisible = true;
                        updatedItem.Funded__c = updatedItem.Funded__c + this.pageData['Amount__c'];
                        updatedItem.progress = (updatedItem.Funded__c / updatedItem.Published_Amount_AUD__c) * 100;
                        updatedItem.disabledButton = true;
                        //console.log('inside if  itemIndex !== -1 updatedItem ', updatedItem);

                        // Create a new array with the updated item
                        const updatedItems = [...this.objdata];
                        updatedItems[itemIndex] = updatedItem;
                        //console.log('updatedItems ', updatedItems);

                        // Update the items array with the new array containing the updated item
                        this.objdata = updatedItems;
                        //console.log('after updating button visibility ', this.objdata);

                    }
                }
            })
            .catch(error => {
                console.log('error from transaction record insert ', error)
                console.log('error from transaction record insert ', JSON.stringify(error))
                console.log('error.body.pageErrors[0].message ', error.body.pageErrors[0].message)
                this.errorTransaction = true;
                this.errorMessageOnTransaction = error.body.pageErrors[0].message;

            })

        /*console.log('currentRecordItem ', currentRecordItem)
        this.currentRecordId = [...this.currentRecordId, currentRecordItem];
        console.log('currentRecordItem after copying ', this.currentRecordId)*/


        /*if (!isNaN(event.target.dataset.id) && event.target.dataset.id >= 0 && event.target.dataset.id < this.objdata.length) {
            //console.log('inside if ')
            this.objdata[event.target.dataset.id].Funded__c = this.objdata[event.target.dataset.id].Funded__c + this.selectedAmount;
            this.objdata[event.target.dataset.id].progress = (this.objdata[event.target.dataset.id].Funded__c / this.objdata[event.target.dataset.id].Published_Amount_AUD__c) * 100;
            //console.log('this.objdata[event.target.dataset.id].Funded__c ',this.objdata[event.target.dataset.id].Funded__c)
            this.objdata = [...this.objdata]; // Trigger a reactivity update
            //console.log('this.objdata ',this.objdata)
        }*/
        this.selectedAmount = 50;

        }
    }
    handleDelete(event) {
        const itemId = event.detail.TransactionId;
        const loanId = event.detail.Id;
        const selectedAmount = event.detail.selectedAmount;
        const oldFunded = event.detail.OldFunded;
        console.log('itemId from navbar ', itemId);
        console.log('before filter ', this.currentRecordId);
        this.currentRecordId = this.currentRecordId.filter((item) => item.TransactionId !== itemId);
        console.log('after filter ', this.currentRecordId);
        console.log('before filter ', this.objdata);
        const matchingObjDataIndex = this.objdata.findIndex(
            objRecord => objRecord.Id == loanId
            
        );
        console.log('matchingObjDataIndex ', matchingObjDataIndex);
        // Check if a matching record was found in objdata
        if (matchingObjDataIndex !== -1) {
            // Update the isButtonVisible property to false
            this.objdata[matchingObjDataIndex].isButtonVisible = false;
            this.objdata[matchingObjDataIndex].Funded__c = this.objdata[matchingObjDataIndex].oldFunded;// - selectedAmount;
            this.objdata[matchingObjDataIndex].disabledButton = false;
            this.objdata[matchingObjDataIndex].progress = (this.objdata[matchingObjDataIndex].Funded__c /this.objdata[matchingObjDataIndex].Published_Amount_AUD__c) *100;
            this.objdata[matchingObjDataIndex].selectedAmount = selectedAmount;
            this.objdata[matchingObjDataIndex].fundingOptions = this.objdata[matchingObjDataIndex].fundingOptions.map(option => {
                        option.selected = option.value == selectedAmount;
                        return option;})
            // Trigger any necessary component updates
            this.objdata = [...this.objdata]; // Force reactivity
        }

        if(this.flRecord[0].Id == loanId){
                    this.flRecord[0].isButtonVisible = false;
                    this.flRecord[0].Funded__c = this.flRecord[0].oldFunded;// - selectedAmount;
                    this.flRecord[0].disabledButton = false;
                    this.Funded__c = this.flRecord[0].Funded__c;
                    this.progress = (this.flRecord[0].Funded__c / this.flRecord[0].Published_Amount_AUD__c) * 100;
                    this.fundingOptions = this.getFundingOptions(Number(this.flRecord[0].Published_Amount_AUD__c) - Number(this.flRecord[0].Funded__c));
                    this.addToCartButton = true;
                    this.checkOutButton = false;
                    this.disabledButton = false;
                    this.flRecord = [...this.flRecord];
                    console.log('after delete from cart this.flrecord ', this.flRecord)
                }
        


    }
    handleDeletesAllAfterTimeout(event) {
        
        const selectedRecords = event.detail;
        console.log('inside mass reset the loan items ',selectedRecords);
        for (const record of selectedRecords) {
            const itemId = record.Id;
            const selectedAmount = record.selectedAmount;
            this.currentRecordId = [];
            // Your existing code to filter records by itemId, update objdata, and flRecord
            const matchingObjDataIndex = this.objdata.findIndex(
            objRecord => objRecord.Id == itemId
            );

            if (matchingObjDataIndex !== -1) {
            // Update the isButtonVisible property to false
            this.objdata[matchingObjDataIndex].isButtonVisible = false;
            this.objdata[matchingObjDataIndex].Funded__c = this.objdata[matchingObjDataIndex].Funded__c - selectedAmount;
            this.objdata[matchingObjDataIndex].disabledButton = false;
            this.objdata[matchingObjDataIndex].progress = (this.objdata[matchingObjDataIndex].Funded__c /this.objdata[matchingObjDataIndex].Published_Amount_AUD__c) *100;
            // Trigger any necessary component updates
            this.objdata = [...this.objdata]; // Force reactivity
            }

            if(this.flRecord[0].Id == loanId){
                        this.flRecord[0].isButtonVisible = false;
                        this.flRecord[0].Funded__c = this.flRecord[0].Funded__c - selectedAmount;
                        this.flRecord[0].disabledButton = false;
                        this.Funded__c = this.flRecord[0].Funded__c;
                        this.progress = (this.flRecord[0].Funded__c / this.flRecord[0].Published_Amount_AUD__c) * 100;
                        this.addToCartButton = true;
                        this.checkOutButton = false;
                        this.disabledButton = false;
                        this.flRecord = [...this.flRecord];
                        console.log('after delete from cart this.flrecord ', this.flRecord)
                    }

            console.log('Processed record: ', record);
        }
        
                


    }
    closeErrorPopup() {
        this.errorTransaction = false;
        this.errorMessageOnTransaction = '';
    }
    selectedAmount = 50.00;
    handleChangeSelectFL(event){
        this.selectedAmount = Number(event.target.value);
        console.log('this.selectedAmount---onselect', this.selectedAmount);
        console.log('fl record funding options ',this.fundingOptions);
            this.fundingOptions = this.fundingOptions.map(option => {
                        option.selected = option.value == this.selectedAmount;
                        return option;
                    });
        console.log('fl record funding options after ',this.fundingOptions);
    }
    handleChangeSelect(event) {

        this.selectedAmount = Number(event.target.value);
        this.buttonMessage = 'Add to cart';
        this.addToCartButton = true;
        this.checkOutButton = false;
        console.log('this.selectedAmount---onselect', this.selectedAmount);
        


        

        const itemId = this.objdata[event.target.dataset.id].Id;
        //console.log('clicked items id ', itemId);

        // Find the clicked item index in the array
        const itemIndex = this.objdata.findIndex(item => item.Id === itemId);
        //console.log('itemIndex ',itemIndex)
        if (itemIndex !== -1) {
            // Create a copy of the item and update its isButtonVisible property
            const updatedItem = { ...this.objdata[itemIndex] };
            updatedItem.isButtonVisible = false;
            updatedItem.selectedAmount = this.selectedAmount;
            updatedItem.fundingOptions = updatedItem.fundingOptions.map(option => {
                        option.selected = option.value == this.selectedAmount;
                        return option;
                    });
            //console.log('after changed the option value ', JSON.stringify(updatedItem.fundingOptions))
            // Create a new array with the updated item
            const updatedItems = [...this.objdata];
            updatedItems[itemIndex] = updatedItem;

            // Update the items array with the new array containing the updated item
            this.objdata = updatedItems;
        }
        


    }

    gotoBorrowersPageFL() {
        //console.log('fl loan id ', this.FLId)
        window.location.assign('careborrowers?loanId=' + btoa(this.FLId))

    }
    gotoBorrowersPage(event) {


        const recordId = event.target.dataset.id;
        window.location.assign('careborrowers?loanId=' + btoa(recordId))

    }





    flRecord = [];
    fundingOptions;
    // for displaying future loan
    @wire(loanRecord)
    loadVal(pageValue) {
        const { data, error } = pageValue;
        const storedArray = JSON.parse(localStorage.getItem('myArray'));
        console.log('storedArray : ',JSON.stringify(storedArray));

        if (data) {
            //console.log('returned records 499 '+JSON.stringify(data));
            //console.log('returned records '+typeof data);
            
            this.flRecord = data.map((loan) => ({
                Id: loan.Id,
                Funded__c: Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0 + Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0 ,
                Published_Amount_AUD__c: parseFloat(loan.Published_Amount_AUD__c).toFixed(2), // Format the numeric field
                Loan_Title__c: loan.Loan_Title__c,
                Country__c: ((loan.Borrower__r?.Postcode__c) ? loan.Borrower__r?.Postcode__c : '') + ' ' + loan.Borrower__r?.Country__c,
                Loan_Description__c: loan.Loan_Purpose__c,
                Loan_Type__c: loan.Loan_Type__c,
                //message: loan.message,
                //progress: (loan.Funded__c / loan.Published_Amount_AUD__c) * 100,
                CreatedDate: loan.CreatedDate,
                progress: ((Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0 + Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0) / loan.Published_Amount_AUD__c) * 100,
                fullyFunded: Math.floor((Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0 + Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0)) >= Math.floor(loan.Published_Amount_AUD__c),
                /*fundingOptions: this.getFundingOptions(parseFloat(loan.Published_Amount_AUD__c - (Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0 + Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0).toFixed(2))),*/
                fundingOptions: this.getFundingOptions(
                parseFloat(loan.Published_Amount_AUD__c - 
                ( 
                (Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0) + 
                (Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0)
                ).toFixed(2))),
                Location_of_Business__c: loan.Location_of_Business__c,
                Name: loan.Name,
                disabledButton: Math.floor(loan.Amount_Funded__c) >= Math.floor(loan.Published_Amount_AUD__c),
                Published_Date__c: loan.Published_Date__c,
                selectedAmount:50,
            }));
            console.log('fl loan as object ', JSON.stringify(this.flRecord[0]));
            const updatedObjdata = [...this.flRecord]
            if (storedArray) {
                storedArray.forEach(storedRecord => {
                    // Find the corresponding record in objdata based on a unique identifier
                    const matchingObjDataRecordIndex = updatedObjdata.findIndex(
                        objRecord => objRecord.Id === storedRecord.Id
                    );

                    // Check if a matching record was found in objdata
                    if (matchingObjDataRecordIndex !== -1) {
                        // Update fields in objdata record with values from storedArray
                        updatedObjdata[matchingObjDataRecordIndex].isButtonVisible = storedRecord.isButtonVisible;
                        updatedObjdata[matchingObjDataRecordIndex].Funded__c = storedRecord.Funded__c + storedRecord.selectedAmount;
                        updatedObjdata[matchingObjDataRecordIndex].progress = storedRecord.progress;
                        updatedObjdata[matchingObjDataRecordIndex].disabledButton = true;
                        updatedObjdata[matchingObjDataRecordIndex].TransactionId = storedRecord.TransactionId;
                        updatedObjdata[matchingObjDataRecordIndex].fundingOptions = storedRecord.fundingOptions;
                        // Add more fields as needed
                    }
                });
                console.log('updatedObjdata : ',JSON.stringify(updatedObjdata));
                this.flRecord = updatedObjdata;
                if(this.flRecord[0].TransactionId != null){
                    this.addToCartButton = false;
                    this.checkOutButton = true;
                    this.disabledButton = true;
                }
                //console.log('fl loan after update from storage ', this.flRecord)
            }
            //console.log('before assigning from this.flRecord[0] ' , JSON.stringify(this.flRecord[0]))
            this.FLId = this.flRecord[0].Id;
            this.Loan_Title__c = this.flRecord[0].Loan_Title__c;
            this.loc = this.flRecord[0].Country__c;
            this.Loan_Type__c = this.flRecord[0].Loan_Type__c;
            this.Loan_Description__c = this.flRecord[0].Loan_Description__c;
            this.Funded__c = parseFloat(this.flRecord[0].Funded__c).toFixed(2);
            this.Published_Amount_AUD__c = this.flRecord[0].Published_Amount_AUD__c;
            //this.progress = (data[0].Funded__c / data[0].Published_Amount_AUD__c) * 100;
            this.progress = this.flRecord[0].progress;
            this.isFullyFunded = this.flRecord[0].fullyFunded;
            this.fundingOptions = this.flRecord[0].fundingOptions;//this.getFundingOptions((parseFloat(this.flRecord[0].Published_Amount_AUD__c).toFixed(2) - this.flRecord[0].Funded__c.toFixed(2)))
            //console.log('after assigning from this.flRecord[0] ' , JSON.stringify(this.flRecord[0]))
            if( this.FLId ){
                this.featuredLoanImg();
            }
        } else if (error) {
            console.log('Error occured ' + JSON.stringify(error));
        }
    }
    //for featured loan
    get fundingOptions() {
        const options = [];
        //for (let i = 1000; i <= this.remainingLoanAmount; i += 1000) {
        options.push({ label: `$${(this.Published_Amount_AUD__c - this.Funded__c).toFixed(2)}`, value: Number(this.Published_Amount_AUD__c - this.Funded__c).toFixed(2) });
        //}
        return options;
    }
    //for list of loans
    getFundingOptions(item) {
        const options = [];

        for (let i = 0; i < this.amountsFromSettings.length; i++) {
            //for( const i in this.amountsFromSettings){

            if (Number(this.amountsFromSettings[i]) < item && this.amountsFromSettings[i] != '') {
                options.push(
                    {
                        label: `$${this.amountsFromSettings[i]}`,
                        value: Number(this.amountsFromSettings[i]).toFixed(2),
                        selected: Number(this.amountsFromSettings[i]).toFixed(2) == 50.00,
                    }
                );
            }
        }
        options.push({ label: `$${Number(item).toFixed(2)}`, value: Number(item).toFixed(2) });
        //}

        /*options.forEach((option, index) => {
            option.selected = index === '50.00';
        });*/
        /*console.log('this.amountsFromSettings.length ', this.amountsFromSettings.length)
        console.log('item ', item)
        console.log('FundingOptions', options)*/
        return options;
    }

    getFundingOptionsCart(item,selAmt) {
        const options = [];

        for (let i = 0; i < this.amountsFromSettings.length; i++) {
            //for( const i in this.amountsFromSettings){

            if (Number(this.amountsFromSettings[i]) < item && this.amountsFromSettings[i] != '') {
                options.push(
                    {
                        label: `$${this.amountsFromSettings[i]}`,
                        value: Number(this.amountsFromSettings[i]).toFixed(2),
                        selected: Number(this.amountsFromSettings[i]).toFixed(2) ==Number(selAmt),
                    }
                );
            }
        }
        options.push({ label: `$${Number(item).toFixed(2)}`, value: Number(item).toFixed(2) });
        //}

        /*options.forEach((option, index) => {
            option.selected = index === '50.00';
        });*/
        /*console.log('this.amountsFromSettings.length ', this.amountsFromSettings.length)
        console.log('item ', item)
        console.log('FundingOptions', options)*/
        return options;
    }

    @wire(allLoanRecords, { loanType: '$loanType', businessLocation: '$businessLocation', sortBy: '$sortBy', pageNumber: null, pageSize: null })
    allLoanRecords1(allLoanValue1) {
        const { data, error } = allLoanValue1;
        //this.wiredAllLoans = allLoanValue1;

        if (data) {
            console.log('no of all loans records 541 ', data.length)
            this.TotalNoOfLoans = data.length;
        }

    }


    // display all loans
    @wire(allLoanRecords, { loanType: '$loanType', businessLocation: '$businessLocation', sortBy: '$sortBy', pageNumber: '$idsArray', pageSize: '$PAGE_SIZE' })
    allLoanRecords(allLoanValue) {
        const { data, error } = allLoanValue;
        this.wiredAllLoans = allLoanValue;
        console.log('returned records', allLoanValue);
        //console.log('returned records length', Object.keys(allLoanValue).length);

        if (data) {
            //console.log('returned records-- ',data);
            this.idsArrayTemp = data.map(item => item.Id);
            // var contentDistribution = data.ContentDistribution;
            this.objdata = data.map((loan) => ({
                Id: loan.Id,
                Funded__c: (Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0) + (Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0),
                Published_Amount_AUD__c: parseFloat(loan.Published_Amount_AUD__c).toFixed(2), // Format the numeric field
                Loan_Title__c: loan.Loan_Title__c,
                Country__c: ((loan.Borrower__r?.Postcode__c) ? loan.Borrower__r?.Postcode__c : '') + ' ' + loan.Borrower__r?.Country__c,
                Loan_Description__c: loan.Loan_Purpose__c,
                Loan_Type__c: loan.Loan_Type__c,
                //message: loan.message,
                //progress: (loan.Funded__c / loan.Published_Amount_AUD__c) * 100,
                CreatedDate: loan.CreatedDate,
                progress: ((Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0 + Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0) / loan.Published_Amount_AUD__c) * 100,
                fullyFunded: Math.floor(loan.Amount_Funded__c + loan.Expected_Fund_From_Cart__c) >= Math.floor(loan.Published_Amount_AUD__c),
                fundingOptions: this.getFundingOptions(
                parseFloat(loan.Published_Amount_AUD__c - 
                ( 
                (Number(loan.Amount_Funded__c)>0?Number(loan.Amount_Funded__c):0) + 
                (Number(loan.Expected_Fund_From_Cart__c)>0 ? Number(loan.Expected_Fund_From_Cart__c):0)
                ).toFixed(2))),

                Location_of_Business__c: loan.Location_of_Business__c,
                Name: loan.Name,
                disabledButton: Math.floor(loan.Amount_Funded__c) >= Math.floor(loan.Published_Amount_AUD__c),
                Published_Date__c: loan.Published_Date__c,
                selectedAmount:50,
            }));
            //console.log('after mapping all record ',this.objdata)
            var lIds = [];
            for (var val of this.objdata) {
                lIds.push(val.Id);
            }
            //console.log('LOANIIIDDDs:',lIds);
            if (lIds.length > 0) {
                this.fillImgUrl(lIds);
            }
            this.objdataTemp = this.objdata;
            this.NoOfLoans = Object.keys(this.objdataTemp).length;
            if (this.NoOfLoans != this.PAGE_SIZE) {
                this.canLoadmore = false;
            }
            else {
                this.canLoadmore = true;
            }

            this.objdata = this.objdata.sort((a, b) => new Date(b.CreatedDate).getTime() - new Date(a.CreatedDate).getTime());
            //console.log('this.objdata ',this.objdata)
            //console.log('this.idsArray ',this.idsArray)
            const updatedObjdata = [...this.objdata];

            const storedArray = JSON.parse(localStorage.getItem('myArray'));
            if (storedArray) {
                // Use the stored array on your page
                console.log('from view all loans wire ', JSON.stringify(storedArray));
            }
            // Iterate through each record in storedArray
            if (storedArray) {
                storedArray.forEach(storedRecord => {
                    // Find the corresponding record in objdata based on a unique identifier
                    const matchingObjDataRecordIndex = updatedObjdata.findIndex(
                        objRecord => objRecord.Id === storedRecord.Id
                    );

                    // Check if a matching record was found in objdata
                    if (matchingObjDataRecordIndex !== -1) {
                        // Update fields in objdata record with values from storedArray
                        updatedObjdata[matchingObjDataRecordIndex].isButtonVisible = storedRecord.isButtonVisible;
                        updatedObjdata[matchingObjDataRecordIndex].Funded__c = storedRecord.Funded__c + storedRecord.selectedAmount;
                        updatedObjdata[matchingObjDataRecordIndex].progress = storedRecord.progress;
                        updatedObjdata[matchingObjDataRecordIndex].disabledButton = true;
                        updatedObjdata[matchingObjDataRecordIndex].fundingOptions = storedRecord.fundingOptions;

                        // Add more fields as needed
                    }
                });
                this.objdata = updatedObjdata;//.sort((a, b) => new Date(b.Published_Date__c).getTime() - new Date(a.Published_Date__c).getTime());
            }
            // Assign the updated objdata back to the objdata property

            console.log('after updating the button visible 554 line ', this.objdata)
        } else if (error) {
            console.log('Error occured ' + JSON.stringify(error));
        }
    }

    fillImgUrl(loanIds) {
        getContentDistribution({ 'loanIds': loanIds }).then(res => {
            //console.log('LLLIIII:',res);
            if (res != undefined) {
                var loans = [];
                for (var val of this.objdata) {
                    loans.push(val);
                }
                for (var val of loans) {
                    var cd = res != undefined ? res[val.Id] : undefined;
                    if (cd != undefined) {
                        val.imageUrl = cd[0].ContentDownloadUrl;
                    }
                }
                this.objdata = loans;
            }
        }).catch(err => {
            console.log(err);
        })
    }
    resetFilter() {
        this.selectedCategory = 'All types';
        this.PAGE_SIZE = 9;
        this.businessLocation = null;
        this.loanType = null;
        this.objdata = this.objdataTemp;
        this.NoOfLoans = Object.keys(this.objdata).length;

        const buttons = this.template.querySelectorAll('.catogory');
        buttons.forEach(button => {
            if (button.name == 'All types') {
                button.classList.add('selected');
            } else if (button.name == this.selectedButtonId) {
                button.classList.remove('selected');
                this.selectedButtonId = null;
            } else {
                button.classList.remove('selected');
                this.selectedButtonId = null;
            }
        });

        this.selectedLocationValue = '';


        /*this.loanType=null;
        this.PAGE_SIZE=9;
        
        console.log('objdata ', this.objdata)
        console.log('objdatatemp ', this.objdataTemp)
        const selectElement = this.template.querySelector('select');
        console.log('resetFilter selectElement ', selectElement.selectedIndex)
        selectElement.selectedIndex = 0;*/
    }
    alltypes() {
        this.loanType = null;

    }
    ArtHandicrafts() {
        //this.loanType='Art/Handicrafts';
        this.objdata = this.objdataTemp.filter(loanType => loanType.Loan_Type__c.includes('Art/Handicrafts'));
        console.log('after filter objdatatemp ', this.objdataTemp)
        this.NoOfLoans = Object.keys(this.objdata).length;
    }
    CafeRestaurant() {
        //this.loanType='Cafe/Restaurant';
        this.objdata = this.objdataTemp.filter(loanType => loanType.Loan_Type__c.includes('Cafe/Restaurant'));
        this.NoOfLoans = Object.keys(this.objdata).length;
    }
    Garmentfactory() {
        //this.loanType='Garment factory';
        this.objdata = this.objdataTemp.filter(loanType => loanType.Loan_Type__c.includes('Garment factory'));
        this.NoOfLoans = Object.keys(this.objdata).length;
    }
    Farming() {
        //this.loanType='Farming';
        this.objdata = this.objdataTemp.filter(loanType => loanType.Loan_Type__c.includes('Farming'));
        this.NoOfLoans = Object.keys(this.objdata).length;
        //console.log('no of loans from farming ', Object.keys(this.objdata).length)

    }
    Educationtraining() {
        //this.loanType='Education/training';
        this.objdata = this.objdataTemp.filter(loanType => loanType.Loan_Type__c.includes('Education/training'));
        this.NoOfLoans = Object.keys(this.objdata).length;
    }
    BusinessLocationChange(event) {
        this.LocationFilter = event.target.value;
        this.businessLocation = event.target.value;
        this.selectedLocationValue = event.target.value;
        console.log('BusinessLocationChange ', event.target.value)
        console.log('this.selectedLocationValue', this.selectedLocationValue)
        /*this.objdata = this.objdata;
        if(this.LocationFilter != ''){
            this.objdata = this.objdataTemp.filter((item) => {
            //console.log('inside filter ', event.target.value)
            //console.log('loanType.Location_of_Business__c ',item.Location_of_Business__c)
            //console.log('loanType.Loan_Type__c ', item.Loan_Type__c)
            return (item.Location_of_Business__c != undefined && item.Location_of_Business__c == event.target.value ) 
            && item.Loan_Type__c == this.loantypefilter
            }
        );
    
        }
        else{
            this.objdata = this.objdataTemp.filter((item) => {
            //console.log('inside filter ', event.target.value)
            //console.log('loanType.Location_of_Business__c ',item.Location_of_Business__c)
            //console.log('loanType.Loan_Type__c ', item.Loan_Type__c)
            return item.Loan_Type__c == this.loantypefilter
            }
        );
    
        }
        
        console.log('after filter ', this.objdata);*/
        this.NoOfLoans = Object.keys(this.objdata).length;
        console.log('location of business ', event.target.value)

    }

    getFilteredLoans() {
        //refreshApex(this.wiredAllLoans);
        this.isFilter = false;
        this.isSort = false;
        document.body.style.overflow = 'auto';
    }
    getSortedLoans() {
        this.isFilter = false;
        this.isSort = false;
        this.isSorted = false;
        document.body.style.overflow = 'auto';
    }

    LeastToCompleteChange(event) {
        //this.sortBy = event.detail.value;
        this.objdata.sort((a, b) => b.progress - a.progress);
        this.isSorted = true;
        this.selectedCheckBoxId = event.detail.value;
        console.log('selectedCheckBoxId-->' + this.selectedCheckBoxId);
        //console.log('after sort ',JSON.stringify(this.objdata))
        //refreshApex(this.wiredAllLoans);


    }
    MostToCompleteChange(event) {
        //this.sortBy = event.detail.value;
        this.objdata.sort((a, b) => a.progress - b.progress);
        this.isSorted = true;
        this.selectedCheckBoxId = event.detail.value;
        console.log('selectedCheckBoxId-->' + this.selectedCheckBoxId);
        //console.log('after sort ',JSON.stringify(this.objdata))
        //refreshApex(this.wiredAllLoans);
        //this.isFilter=false;
        //this.isSort=false;

    }
    OldestLoanChange(event) {
        //this.sortBy = event.detail.value;
        //refreshApex(this.wiredAllLoans);
        //this.objdata.sort((a, b) => a.CreatedDate - b.CreatedDate);
        this.objdata = this.objdata.sort((a, b) => new Date(a.Published_Date__c).getTime() - new Date(b.Published_Date__c).getTime());

        this.isSorted = true;
        this.selectedCheckBoxId = event.detail.value;
        console.log('selectedCheckBoxId-->' + this.selectedCheckBoxId);
        //this.isFilter=false;
        //this.isSort=false;

    }
    MostRecentLoanChange(event) {
        //this.sortBy = event.detail.value;
        //refreshApex(this.wiredAllLoans);
        //this.objdata.sort((a, b) => b.Published_Date__c - a.Published_Date__c);
        this.objdata = this.objdata.sort((a, b) => new Date(b.Published_Date__c).getTime() - new Date(a.Published_Date__c).getTime());

        this.isSorted = true;
        this.selectedCheckBoxId = event.detail.value;
        console.log('selectedCheckBoxId-->' + this.selectedCheckBoxId);
        //this.isFilter=false;
        //this.isSort=false;
    }
    get searchBg() {
        return `background-image: url('${this.greenfield}');background-size: cover; background-repeat: no-repeat;`;
    }

    get LeastToCompleteOption() {
        return [
            { label: '', value: 'Least To Complete' },

        ];
    }
    get MostToCompleteOption() {
        return [
            { label: '', value: 'Most To Complete' },

        ];
    }
    get OldestLoanOption() {
        return [
            { label: '', value: 'Oldest Loan' },

        ];
    }
    get MostRecentLoanOption() {
        return [
            { label: '', value: 'Most Recent Loan' },

        ];
    }

    closeFilterMenu() {
        this.isFilter = false;
        document.body.style.overflow = 'auto';
    }

    openFilter() {
        this.isFilter = true;
        document.body.style.overflow = 'hidden';
    }

    openSort() {
        this.isSort = true;
        document.body.style.overflow = 'hidden';
    }

    closeSortMenu() {
        this.isSort = false;
        document.body.style.overflow = 'auto';
        this.isSorted = false;
    }


    get comboboxOptions() {
        return [
            { label: '$25', value: 1 },

        ];
    }
    value = 1;
    get combobox1Options() {
        return [
            { label: 'All Locations', value: 'all' },

        ];
    }

    get backgroundImage() {

        this.getScreenSize();



        if (this.screenWidth <= 414 && this.screenHeight <= 915) {
            return MicrofinanceMobileBanner;
            //return `background-image: url('${this.OurImpactBanner1}');background-size: cover; background-repeat: no-repeat;`;
        }
        else {
            return MicroFinanceBanner;
            //return `background-image: url('${this.OurImpactBanner}');background-size: cover; background-repeat: no-repeat;Height:532px;`;
        }

    }
    flImg;
    featuredLoanImg(){
        if(this.FLId){
            console.log('FL ID:',this.FLId);
            getContentDistribution({ 'loanIds': [this.FLId] }).then(res => {
                //console.log('LLLIIII:',res);
                if (res != undefined) {
                    var cd = res != undefined ? res[this.FLId] : undefined;
                    if (cd != undefined) {
                        this.flImg = cd[0].ContentDownloadUrl;
                    }
                }
                console.log( 'FL Img:',res );
            }).catch(err => {
                console.log(err);
            })
        }
    }
    connectedCallback() {
        LWCConfigSettingMetadata()
            .then(result => {
                console.log('from connectedc call back amounts ', result);
                this.amountsFromSettings = result.Loan_Amounts__c.split(';');
                console.log('this.amountsFromSettings from conn ', JSON.stringify(this.amountsFromSettings))
                this.PAGE_SIZE = 9;
            })
        this.getScreenSize();

        // Retrieve the array from local storage
        console.log('lloc');
        const storedArray = JSON.parse(localStorage.getItem('myArray'));
        console.log('lloc2 889 ', storedArray);
        const noJsonvalue = localStorage.getItem('myArray');
        console.log('noJsonvalue -> ', noJsonvalue);
        console.log('noJsonvalue -> ', typeof (noJsonvalue));


        if (storedArray) {
            // Use the stored array on your page
            this.myArray = storedArray;
            //this.currentRecordId = noJsonvalue;
            this.currentRecordId = [...this.currentRecordId, ...storedArray];
            console.log('from view all loans ', storedArray);
            console.log('from view all loans--> ', this.currentRecordId);

        } else {
            // Handle the case where the array hasn't been stored yet
            console.log('Array not found in local storage');
        }
        console.log('kk');
        window.addEventListener('resize', this.getScreenSize.bind(this));
        window.addEventListener('scroll', () => this.handleScroll()); // Use arrow function
        console.log('kk2');
        //this.NoOfLoans = this.PAGE_SIZE;
        //this.PAGE_SIZE = 1;
        //console.log('initial value ', this.PAGE_SIZE)
    }


    renderedCallback() {
        //console.log('ele');
        const progressBarElements = this.template.querySelectorAll('.progressBarInner');
        //console.log('ele2');

        // Fetch your JSON data here (e.g., using fetch, import, or received from parent component)
        if (progressBarElements) {
            // Loop through each progress bar element and set its styles based on JSON data
            progressBarElements.forEach((progressBar) => {
                const progressValue = (progressBar.dataset.value >= 98.70) ? 99.00 : progressBar.dataset.value;//progressBar.dataset.value - 2:progressBar.dataset.value;
                //console.log('progressValue - 2 ', progressValue)
                progressBar.style.width = progressValue + "%";
                if (progressValue < 85) {
                    progressBar.style.backgroundColor = "#FEBE10";
                } else {
                    progressBar.style.backgroundColor = "#5C8F39";
                }
            });
        }


        /*const disabledButtonElements = this.template.querySelectorAll('.CarouselAddtocartButton');
            
            if(disabledButtonElements){
                disabledButtonElements.forEach((disable) => {
                    const disableValue = disable.dataset.value;
                    console.log('disableValue ', disableValue);
                    if(disableValue){
                        disable.classList.remove('CarouselAddtocartButton','button');
                        console.log('true ', disable);
                    }
                    else{
                        disable.classList.add('CarouselAddtocartButton','button');
                        console.log('false ', disable);
                    }
                    
                })
            }*/

        // Add a class to the selected button using classList
        //console.log('Render - selectedButtonId-->'+this.selectedButtonId);
        if (this.selectedButtonId) {
            const selectedButton = this.template.querySelector(`button[data-id="${this.selectedButtonId}"]`);
            //console.log('Render - selectedButton-->'+selectedButton);
            if (selectedButton) {
                //console.log('Inside Slected Button');
                selectedButton.classList.add('selected');
            }
        }

        if (this.selectedCheckBoxId !== null && this.selectedCheckBoxId == 'Least To Complete') {
            const selectedButton = this.template.querySelector(`lightning-radio-group[data-id="LeastToComplete"]`);
            selectedButton.value = 'Least To Complete';
        } else if (this.selectedCheckBoxId !== null && this.selectedCheckBoxId == 'Most To Complete') {
            const selectedButton = this.template.querySelector(`lightning-radio-group[data-id="MostToComplete"]`);
            selectedButton.value = 'Most To Complete';
        } else if (this.selectedCheckBoxId !== null && this.selectedCheckBoxId == 'Oldest Loan') {
            const selectedButton = this.template.querySelector(`lightning-radio-group[data-id="OldestLoanOption"]`);
            selectedButton.value = 'Oldest Loan';
        } else if (this.selectedCheckBoxId !== null && this.selectedCheckBoxId == 'Most Recent Loan') {
            const selectedButton = this.template.querySelector(`lightning-radio-group[data-id="MostRecentLoan"]`);
            selectedButton.value = 'Most Recent Loan';
        }

        const select = this.template.querySelector('.filterLocations');
        console.log('this.selectedLocationValue--->'+this.selectedLocationValue);
        if ( this.selectedLocationValue != ''&& (select!=''||select!=null)) {
            select.value = this.selectedLocationValue;
        }


    }
    disconnectedCallback() {
        window.removeEventListener('resize', this.getScreenSize);
        window.removeEventListener('scroll', () => this.handleScroll()); // Use arrow function
    }

    getScreenSize() {
        this.screenWidth = window.innerWidth;
        this.screenHeight = window.innerHeight;
    }
    clearLoans() {
        this.loanidfromparent = [];
        localStorage.setItem('myArray', JSON.stringify(this.loanidfromparent));
    }

    @track carouselItemsImpact = [
        {
            id: 1,
            imageUrl: AllLoansHeaderImage,
            title: 'The Climate Load: New report',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Garment Factory',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 2,
            imageUrl: AllLoansHeaderImage,
            title: '“Everybody deserves to be heard.”',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Education',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 3,
            imageUrl: AllLoansHeaderImage,
            title: 'With a surge of natural disasters..',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Agriculture',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 4,
            imageUrl: AllLoansHeaderImage,
            title: 'Climate Change: New alarming report',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Emergency',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 5,
            imageUrl: AllLoansHeaderImage,
            title: 'Textile & Garment Upgrade',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Garment Factory',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 6,
            imageUrl: AllLoansHeaderImage,
            title: 'The Climate Load: New report',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Garment Factory',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 7,
            imageUrl: AllLoansHeaderImage,
            title: 'Textile & Garment Upgrade',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Garment Factory',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        },
        {
            id: 8,
            imageUrl: AllLoansHeaderImage,
            title: '“Everybody deserves to be heard.”',
            location: 'Vitenam',
            description: 'Consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua incididunt eiusmod tempor ut.',
            Lent: '$75 Lent',
            Goal: '$240 Goal',
            Button: 'Add to cart',
            department: 'Garment Factory',
            message: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
        }
    ];
}