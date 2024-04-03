public class LWC_RepaymentScheduleChange {
    
    @InvocableMethod(label='Repayment Schedule Change')
    public static void sendRepaymentScheduleChangeAlert(list<String> loanIds){
            //System.debug('I have ran-->'+loanIds);
            LWC_SendEmailWithTemplateCtrl.sendEmail(null, loanIds[0], null, 'Repayment Schedule Change');
        
    }

}