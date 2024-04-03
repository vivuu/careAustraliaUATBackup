import { LightningElement, track, api } from 'lwc';
import Hamburger from '@salesforce/resourceUrl/HamburgerWhite';
import MagGlass from '@salesforce/resourceUrl/MagnifyingGlass';
import UserIcons from '@salesforce/resourceUrl/NavUser';
import ShoppingCart from '@salesforce/resourceUrl/GroceryStore';
import LendWithCareImages from '@salesforce/resourceUrl/LendWithCareImages';
import LWCLogo from '@salesforce/resourceUrl/LWCLogoSvg';

export default class Lwr_customNav extends LightningElement {
    lendLogo=LendWithCareImages+'/logo.png';
    LenwithCareLogo = LWCLogo;

    @track isMenuOpen = false;
    @track isSearchMenuOpen = false;
    @track isDropdownOpen = false;
    @track isDropdownOpenAbout = false;
    @track loginPage = false;
    violet=false;
    yellow=false;
    ham=Hamburger;
    MGlass=MagGlass;
    UseAvatar=UserIcons;
    shopcart=ShoppingCart;


    OpenHomePage() {
        // window.location.assign('homepage');
        location.assign('');
    }
    openLoansPage(){
        // window.location.assign('careviewallloans');
        location.assign('careviewallloans');
    }
    openBecomeChangeChampion(){
        // window.location.assign('carebecomechangechampion');
        location.assign('carebecomechangechampion');
    }
    openourimpact(){
        // window.location.assign('ourimpact');
        location.assign('ourimpact');
    }
    openaboutus(){
        // window.location.assign('aboutus');
        location.assign('aboutus');
    }
    opencarehelpcentre(){
        // window.location.assign('carehelpcentre');
        location.assign('carehelpcentre');
    }
    opencaredashboard(){
        // window.location.assign('caredashboard');
        location.assign('caredashboard');
    }
    openLogin(){
        // window.location.assign('login');
        location.assign('login');
    }

    connectedCallback() {
        console.log('window.location.href');
        console.log(window.location.href);

        console.log('document.URL');
        console.log(document.URL);
       const currentPageUrl =location.href;
        // const currentPageUrl = window.location.href;
        console.log('Current page URL:', currentPageUrl);
        if(currentPageUrl.includes('careviewallloans')){
            this.isVisible=false;
        }
        else if(currentPageUrl.includes('homepage')){
            this.violet=true;
        }
        else if(currentPageUrl.includes('careborrowerspage')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('aboutmicrofinancing')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('aboutus')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('ourimpact')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('carecontactus')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('carenewsandupdates')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('careblogpost')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('carehelpcentre')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('carebecomechangechampion')){
            this.yellow=true;
        }
        else if(currentPageUrl.includes('caresearchresults')){
            this.yellow=true;
        }
        
    }
    openLoginPage() {
        this.loginPage = true;
    }

    openMenu() {
        console.log('Js Inside');
        this.isMenuOpen = true;
    }

    closeMenu() {
        this.isMenuOpen = false;
    }

    SearchMenuOpen(){
        this.isSearchMenuOpen = true;
    }

    closeSearchMenu(){
        this.isSearchMenuOpen = false;
    }

    toggleDropdown() {
    this.isDropdownOpen = !this.isDropdownOpen;
  }

      toggleDropdownAbout() {
    this.isDropdownOpenAbout = !this.isDropdownOpenAbout;
  }
    
}