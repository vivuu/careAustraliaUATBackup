@istest
public class LWCAdminSettingsCtrlTest {
    Public  testmethod static void adminSettings()
    {
        Test.startTest();
        LWCAdminSettingsCtrl.executeOffsetCalculationManually();
        LWCAdminSettingsCtrl.updateFXRatesManually();
        Test.stopTest();
    }
}