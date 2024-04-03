@isTest
public class LWR_SelfReg_Ctrl_Test {
    @isTest
    public static void testM1(){
        String email = 'test@test.com'+Math.random()*100;
        Test.startTest();
        LWR_SelfReg_Ctrl.checkEmail(email);
        LWR_SelfReg_Ctrl.checkEmail(UserInfo.getUserName());
        Test.stopTest();
    }
    
    @isTest
    public static void testM2(){
        Test.startTest();
            LWR_SelfReg_Ctrl.registerLenderExtUser('Mr','Firstname', 'Lastname', 'test@test.com'+Math.random()*100000, '123456', Date.valueOf('1953-01-22'), '12356897', true,'qwerT123456789$','StartURL');
			LWR_SelfReg_Ctrl.RegistrationStatus rs = new LWR_SelfReg_Ctrl.RegistrationStatus();
        rs.success = false;
        rs.returnSTR ='test';
        Test.stopTest();
    }
}