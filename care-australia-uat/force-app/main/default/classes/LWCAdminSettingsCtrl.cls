public without sharing class LWCAdminSettingsCtrl {
    @AuraEnabled
    public static void executeOffsetCalculationManually(){
      LWCUtility.executeOffsetCalculationManually();
    }
    
    // to run the fx rate updates manually, need to call this method on click of a button from the LWC Settings page
    @AuraEnabled
    public static void updateFXRatesManually(){
       LWCUtility.updateFXRatesManually();
    }
}