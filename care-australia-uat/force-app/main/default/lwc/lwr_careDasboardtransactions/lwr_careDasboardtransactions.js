import { LightningElement, track, api, wire } from 'lwc';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import Mfpara2 from '@salesforce/resourceUrl/Mfpara2';
import para4 from '@salesforce/resourceUrl/para4';
import farm from '@salesforce/resourceUrl/farm';
import img5 from '@salesforce/resourceUrl/img5';
import stichingwomen from '@salesforce/resourceUrl/stichingwomen';
import img3 from '@salesforce/resourceUrl/img3';
import MicroFinanceBanner from '@salesforce/resourceUrl/MicroFinanceBanner';
import MicrofinanceMobileBanner from '@salesforce/resourceUrl/MicrofinanceMobileBanner';
import getYourTransactionDetails from '@salesforce/apex/LWC_AllLoansCtrl.getYourTransactionDetails';
import Amount from '@salesforce/schema/Opportunity.Amount';
import downloadPDF from '@salesforce/apex/CareHomePageCtrl.getPdfFileAsBase64String';
import getCurrentUser from '@salesforce/apex/LWC_AllLoansCtrl.getCurrentUser';
import basePath from '@salesforce/community/basePath';

const columns = [
  { label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date', initialWidth: 150 },
  { label: 'Type', fieldName: 'Type__c', initialWidth: 100 },
  { label: 'Amount', fieldName: 'Amount__c', initialWidth: 100 },
  {
    label: 'Download', type: 'button-icon',
    initialWidth: 50,
    typeAttributes: {
      iconName: 'utility:download',
      name: 'download',
      title: 'Download',
      disabled: { fieldName: 'disableDownloadButton' },
      variant: 'bare',
      alternativeText: 'Download'
    },
    cellAttributes: {
      class: { fieldName: 'downloadButtonClass' }
    }
  }
];

export default class Lwr_careDasboardtransactions extends LightningElement {
    spin = false;
  @track isLoading = false;
  @track isSelected = false;
  @track showButton = true;
  @track screenWidth;
  @track screenHeight;
  @track contactid;
  @track transactions = [];
  @track type = 'All'
  @track showAll = true;
  columns = columns;
  dashboardLink;
  selectedButtonId;

  lendLogo = LendWithCareImages + '/logo.png';
  Mfpara2 = Mfpara2;
  farm = farm;
  para4 = para4;
  img3 = img3;
  img5 = img5;
  stichingwomen = stichingwomen;
  isFilter = false;
  isSort = false;
  value = '';
  selectedfilterType = 'All';
  sortValue = 'MostRecent';
  fromAmount = '';
  toAmount = '';
  fromDate = '';
  toDate = '';
  filterValues = null;
  showTable = false;
  @wire(getYourTransactionDetails, { type: '$type', contactId: '$contactid', showAll: '$showAll', sortValue: '$sortValue', filterValues: '$filterValues'}) //: { type: "All", fromAmount: "100", toAmount: "200", fromDate: "2023-08-10", toDate: "2023-09-22" }
  wiredTransactionData({ error, data }) {
    console.log('Wireee');
    this.isLoading = false;

    // let formattedDate = new Date(data[0].Completed_Date__c).toLocaleDateString("en-GB");
    console.log('@wire DATA: ' + JSON.stringify(this.type)+'  , '+JSON.stringify(this.contactid)+' , '+JSON.stringify(this.showAll)+' , '+JSON.stringify(this.showAll)+' , '+JSON.stringify(this.sortValue)+' , '+JSON.stringify(this.filterValues));

    if (data) {
      this.transactions = data.map((transaction) => ({
        ...transaction,
        disableDownloadButton: transaction.Type__c !== 'Donation',
        downloadButtonClass: transaction.Type__c === 'Donation' ? 'slds-show' : 'slds-hide',
      }));
      if( this.transactions!=undefined && this.transactions.length >0 ){
        this.showTable = true;
      } else{
        this.showTable = false;
      }
    } else {
      console.error('Error loading data:', error);
    }
  }

  formatCompletedDate(dateString) {
    const date = new Date(dateString);
    const day = date.getDate().toString().padStart(2, '0');
    const month = (date.getMonth() + 1).toString().padStart(2, '0'); // Months are 0-based
    const year = date.getFullYear();
    return `${day}-${month}-${year}`;
}

  openFilter() {
    this.isFilter = true;
    this.isSort = false;
  }

  closeFilterMenu() {
    this.isFilter = false;
  }


  openSort() {
    this.isFilter = false;
    this.isSort = true;
  }

  closeSortMenu() {
    this.isSort = false;
  }


  // Get Options on clicking of radio button

  get MostRecentradioOptions() {
    return [
      { label: '', value: 'MostRecent' },

    ];
  }
  get OldestradioOptions() {
    return [
      { label: '', value: 'Oldest' },

    ];
  }
  get HighestLowestradioOptions() {
    return [
      { label: '', value: 'HighestLowest' },

    ];
  }
  get LowestHighestradioOptions() {
    return [
      { label: '', value: 'LowestHighest' },

    ];
  }
  MostRecentChange(event) {
    if( this.sortValue!='MostRecent' ){
      this.sortValue = 'MostRecent';
      this.isLoading = true;
    }
    console.log('sortValue: ' + this.sortValue);
  }
  OldestChange(event) {
    if( this.sortValue!='Oldest' ){
      this.sortValue = 'Oldest';
      this.isLoading = true;
      console.log('sortValue: ' + this.sortValue);
    }

  }
  HighestLowestChange(event) {
    if( this.sortValue!='HighestLowest' ){
      this.sortValue = 'HighestLowest';
      this.isLoading = true;
      console.log('sortValue: ' + this.sortValue);
    }
  }
  LowestHighestChange(event) {
    if( this.sortValue!='LowestHighest' ){
      this.sortValue = 'LowestHighest';
      this.isLoading = true;
      console.log('sortValue: ' + this.sortValue);
    }
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
  connectedCallback() {
    // const currentPageUrl = window.location.href;
    const currentPageUrl = location.href;
    // var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s') + 3);
    var currentPageUrl2 = currentPageUrl.substring(0, currentPageUrl.indexOf('/s'));
    this.dashboardLink = 'caredashboard';
    this.extractContactIdFromUrl();
    this.getScreenSize();
    window.addEventListener('resize', this.getScreenSize.bind(this));
    console.log('transactions connected call back ')
  }
  disconnectedCallback() {
    window.removeEventListener('resize', this.getScreenSize);
  }

  renderedCallback(){

        if (this.selectedButtonId) {
        const selectedButton = this.template.querySelector(`button[data-id="${this.selectedButtonId}"]`);
        //console.log('Render - selectedButton-->'+selectedButton);
        if (selectedButton) {
            //console.log('Inside Slected Button');
            selectedButton.classList.add('selectedFilter');
        }
    }
  }
    resetFiltervalues(){
    this.selectedfilterType = 'All';
    this.type = 'All';
    this.sortValue = 'MostRecent';
    this.fromAmount = '';
    this.toAmount = '';
    this.fromDate = '';
    this.toDate = '';
    this.filterValues = {};
    console.log('Refreshing data');
    console.log(this.type, this.sortValue);
    

    const buttons = this.template.querySelectorAll('.catogory');
    console.log('selectedButtonId-->'+this.selectedButtonId);
        buttons.forEach(button => {
            if (button.name == 'All') {
                button.classList.add('selectedFilter');
            } else if (button.name == this.selectedButtonId) {
                button.classList.remove('selectedFilter');
                this.selectedButtonId = null;
            } else {
                button.classList.remove('selectedFilter');
                this.selectedButtonId = null;
            }
     });
     this.refreshData();
  }

  getScreenSize() {
    this.screenWidth = window.innerWidth;
    this.screenHeight = window.innerHeight;
  }

  extractContactIdFromUrl() {
    this.spin = true;
    // const urlParams = new URLSearchParams(window.location.search);
    const urlParams = new URLSearchParams(location.search);
    var Id = urlParams.get('Id');
    //this.contactid = atob(Id); // decrypt the ID from care dashboard
    /* if( this.contactid == undefined || this.contactid=='' || this.contactid==null ){
      const currentUrl = window.location.href;
      const newUrllogin = currentUrl.replace(/\/s\/[^/]+/, '/s/' + 'login/');
      window.location.assign(newUrllogin);
    } */
    // const lUrl = window.location.href;
    const lUrl = location.href;
    if(!lUrl.includes('builder.salesforce-experience.com') && !lUrl.includes('salesforce-experience.com')){
        getCurrentUser()
      .then(result => {
          if (result.Contact.Id == null || result.Contact.Id==undefined || result.Contact.Id=='') {
              // const currentUrl = window.location.href;
              const currentUrl = location.href;
              //const newUrllogin = currentUrl.replace(/\/s\/[^/]+/, '/s/' + 'login/');
              const newUrllogin = basePath+ '/' + 'login/';
              // window.location.assign(newUrllogin);
              location.assign(newUrllogin);
          } 
          this.contactid = Id;
          this.spin = false;
          /* if( this.contactid!=undefined ){
              this.getContactFields();
          } */
      })
      .catch(error => {
          // this.spin = false;
          console.log('Error:',error);
          // const currentUrl = window.location.href;
          const currentUrl = location.href;
         // const newUrllogin = currentUrl.replace(/\/s\/[^/]+/, '/s/' + 'login/');
         const newUrllogin = basePath+ '/' + 'login/';
          // window.location.assign(newUrllogin);
          location.assign(newUrllogin);
          this.contactid = Id;
      })
    }
    console.log('this.contactId @@@ : ' + this.contactid);
  }

  handleButtonClick(event) {
    this.type = event.target.dataset.type;
    if (this.selectedType === this.type) {
      this.selectedType = ''; // Unselect if clicked again
    } else {
      this.selectedType = this.type;
    }
    this.isLoading = event.target.dataset.type === 'All' ? false : true;
    this.refreshData();
    this.isSelected = !this.isSelected;
    console.log('@@@@@dataset' + event.target.dataset.type);
  }
  refreshData() {
    console.log('Refreshingg');
    refreshApex(this.wiredTransactionData).then(() => {
      // Reset isLoading after data has been refreshed
      this.isLoading = false;
    });
  }

  get onSelection() {
    return this.selectedType === '' ? '' : 'selected';
  }

  handleFilterClick(event) {
    this.selectedfilterType = event.target.dataset.type;
    this.type = this.selectedfilterType;
    console.log('Selected Filter Type:', this.selectedfilterType);

    const selectedButton = event.target;
    const buttons = this.template.querySelectorAll('.catogory');
    buttons.forEach(button => {
        button.classList.remove('selectedFilter');
    });
    selectedButton.classList.add('selectedFilter');

    const clickedButtonId = event.target.getAttribute('data-id');
    console.log('clickedButtonId-->' + clickedButtonId);
    this.selectedButtonId = clickedButtonId;
    console.log('selectedButtonId-->' + this.selectedButtonId);

  }
  // Handle changes for Transaction Amount - From input
  handleFromInputChange(event) {
    this.fromAmount = event.target.value;
  }

  // Handle changes for Transaction Amount - To input
  handleToInputChange(event) {
    this.toAmount = event.target.value;
  }

  // Handle changes for Date Range - From input
  handleFromDateChange(event) {
    this.fromDate = event.target.value;
  }

  // Handle changes for Date Range - To input
  handleToDateChange(event) {
    this.toDate = event.target.value;
  }

  applyFilters() {
    this.isLoading = true;
    this.transactions = [];
    // Prepare filter values
     this.filterValues = {
        type: this.selectedfilterType,
        fromAmount: this.fromAmount,
        toAmount: this.toAmount,
        fromDate: this.fromDate,
        toDate: this.toDate
    };
    this.isFilter = false;
    console.log('this.filterValues:: ' + JSON.stringify(this.filterValues));
    // Call wire method with filter values
    this.refreshData();
}

handleDownload(event){
  try{
      this.spin = true;
      var tId = event.currentTarget.dataset.transactionId;

      downloadPDF({'transactionIds':tId, 'ContactId':this.contactid, 'template':'LWC Donation PDF'}).then(response => {
          const binaryString = atob(response); // Decode the Base64 string to binary
              const byteArray = new Uint8Array(binaryString.length);
              for (let i = 0; i < binaryString.length; i++) {
                  byteArray[i] = binaryString.charCodeAt(i);
              }
              console.log('bStr:',binaryString);
              // Create a Blob from the Uint8Array
              const blob = new Blob([byteArray], { type: 'application/pdf' });
              this.spin = false;
              // Create a temporary anchor element to trigger the download
              const url = window.URL.createObjectURL(blob);
              const a = document.createElement('a');
              a.href = url;
              a.download = 'LWC Donation PDF.pdf';
              document.body.appendChild(a);
              a.click();

              // Cleanup
              window.URL.revokeObjectURL(url);
              document.body.removeChild(a);

      }).catch(error => {
          this.spin = false;
          console.log('Error: ' +error.toString());
          console.log('Error: ' +JSON.parse(JSON.stringify(error)));
          console.log('Error: ' +JSON.stringify(error));
      });
  }catch(err){
      console.log(err);
  }
}
}