@isTest
public class OTPGeneratorTest {
   public testmethod static void testPerformance(){
       Test.startTest();
       OTPGenerator.Requests og=new OTPGenerator.Requests();
       og.otpDigits=6;
       List<OTPGenerator.Requests> testList=new List<OTPGenerator.Requests>();
       testList.add(og);
       OTPGenerator.generateOTP(testList);
       Test.stopTest();
    }

}