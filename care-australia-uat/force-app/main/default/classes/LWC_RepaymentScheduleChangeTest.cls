@isTest
public class LWC_RepaymentScheduleChangeTest {
    @isTest
    public static void RepaymentScheduleChangeTest()
    {
      List<User> lenderUser=[SELECT Id, Name,ContactId FROM User WHERE isActive=true AND Profile.Name='Lender' AND ContactId!=null LIMIT 1];
      List<Loan__c> loans=LWCTestUtility.getBorrowerLoans(LWCTestUtility.getBorrowerRecords(lenderUser));
      List<String> loanIds=new List<String>();
        if(loans!=null)
            loanIds.add(loans[0].Id);
      Test.startTest();
      LWC_RepaymentScheduleChange.sendRepaymentScheduleChangeAlert(loanIds);
        Test.stopTest();
    }
}