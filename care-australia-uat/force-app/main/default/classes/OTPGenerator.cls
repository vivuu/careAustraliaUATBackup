public class OTPGenerator {
    @InvocableMethod(label='Generate OTP' 
                     description='Generates the 6-didgit OTP for Users to login' 
                     category='Login')
    public static List<String> generateOTP(List<Requests> newRequests){
        Integer otpLength = newRequests[0].otpDigits;
        List<String> OTPList = new List<String>();
        String randomDigits = String.valueOf(Math.abs(Crypto.getRandomInteger()));
        String otp = randomDigits.subString(0,otpLength);
        OTPList.add(otp);
        return OTPList;
    }
    
    public class Requests {
    @InvocableVariable(label='OTP Digits' description='Specify the number of digits for OTP' required=true)
    public Integer otpDigits;
  }


}