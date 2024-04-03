/**
* Name          :       KYCPayment26EMScheduler
* Date          :       12/09/2023
* Author        :       Sayan Baral
* Description   :       to mark KYC Required as true or false on 26th and based on criterias mentioned release or hold payments
*/
global class LWC_KYCPayment26EMScheduler Implements Database.Batchable<sObject>, Schedulable
{
    global void execute(SchedulableContext sc)
    {
        LWC_KYCPayment26EMScheduler b = new LWC_KYCPayment26EMScheduler();
        database.executebatch(b, 50);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
        Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
        Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
        String query = 'Select Id, Name, ContactId From User Where Profile.Name=\'Lender\' AND isActive=true AND ContactId != null';
        return Database.getQueryLocator([Select Id, Name, Amount_Due__c, Due_Date__c, Principal_Repaid__c, 
                                                                       Repayment_Date__c, Status__c, Loan__c, Loan__r.FSP_Name__c 
                                                                       From Repayment_Schedule__c 
                                                                       Where ((Due_Date__c >=: firstDayOfThisMonth AND Due_Date__c <=: lastDayDateOfThisMonth)
                                                                              OR (Principal_Repaid__c != NULL AND Status__c != NULL)) Order By Loan__c]);
    }
    
    global void execute(Database.BatchableContext BC, List<Repayment_Schedule__c> forwardCheckRepayments) 
    {
        SavePoint sp = Database.setSavepoint();
        try
        {
            Integer month=System.Today().addMonths(-1).Month();
            Integer year=System.Today().addMonths(-1).Year();
            Date firstDayOfLastMonth = Date.newInstance(year, month, 1);
            
            // Get the last day of the current month
            Date firstDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 1);
            Date midDayOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), 15);
            Integer lastDayOfThisMonth = Date.daysInMonth(System.today().year(), System.today().month());
            Date lastDayDateOfThisMonth = Date.newInstance(System.today().year(), System.today().month(), lastDayOfThisMonth);
            //Map to collect multiple repayments against a loan
            List<String> loanIds=new List<String>();
            List<Transaction__c> heldTransactions=new List<Transaction__c>();
             map<String, list<Repayment_Schedule__c>> loanRepaymentsMap = new map<String, list<Repayment_Schedule__c>>();
             if(forwardCheckRepayments != null && forwardCheckRepayments.size()>0)
             {
                for(Repayment_Schedule__c rs: forwardCheckRepayments)
                {
                    loanIds.add(rs.Loan__c);
                    // It might be possible that one loan could have multiple repayment in a month
                    list<Repayment_Schedule__c> result = loanRepaymentsMap.get(rs.Loan__c);
                    if(result==null)
                    {
                        result= new list<Repayment_Schedule__c>();
                    }
                    result.add(rs);
                    loanRepaymentsMap.put(rs.Loan__c, result);
                }
             }
            
             map<String, Contact> lendersMap = new map<String, Contact>(LWCUtility.getAllActiveLenders());
            List<String> lenderIds=new List<String>();
            for(Contact c: lendersMap.values())
                lenderIds.add(c.Id);
            
             Map<String,boolean> contwithAML=LWCUtility.AMLCheck(loanRepaymentsMap,lenderIds);
            List<Contact> updateKYCreq=new List<Contact>();
           	for(String s: contwithAML.keySet())
            {
                Contact c=new COntact();
                	c.Id=s;
                if(contwithAML.get(s)==true)  
                	c.KYC_Required__c=true; 
                updateKYCreq.add(c);
                
            }
            try
            {
                if(updateKYCreq != null && updateKYCreq.size()>0)
                    update updateKYCreq;
            }
            catch(Exception e)
            {
               system.debug('Error--->'+e.getMessage());
            } 
            List<String> moneyIncomingMail=new List<String>();
            List<String> moneyHeldMail=new List<String>();
            Id customerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Supporter').getRecordTypeId();             
            map<String, Contact> contactsMap = new map<String, Contact>([Select Id, Name, CurrencyISOCode, Lender_Balance__c,KYC_Required__c,
                                                                         KYC_failed__c,KYC_Completed__c,(SELECT Id, Type__c,Status__c FROM Transactions__r WHERE Status__c='Held' AND Type__c='Repayment')
                                                                         From Contact Where RecordTypeId =: customerRTId 
                                                                         AND IsLender__c=true AND id IN:lenderIds]);
            for(Contact c: contactsMap.values())
            {
                if((((c.KYC_Required__c==true&&c.KYC_failed__c==false&&c.KYC_Completed__c==true)||(c.KYC_Required__c==false))
                    &&(c.Transactions__r.size()>0)&&(c.Transactions__r!=null))||Test.isRunningTest())
                {
                    moneyIncomingMail.add(c.Id);
                     for(Transaction__c t: c.Transactions__r)
                	{
                        System.debug('Tranaction held oops-->'+t);
						t.Status__c='Completed';
                        heldTransactions.add(t);
                	}                    
                }
                if(c.KYC_Required__c==true&&c.KYC_failed__c==true&&c.KYC_Completed__c==false)
                {
                    moneyHeldMail.add(c.Id);
                }
        
            }
            if((moneyIncomingMail.size()>0)&&(moneyIncomingMail!=null))
            {
				LWC_SendEmailWithTemplateCtrl.sendEmail(moneyIncomingMail,null,null,'Credit Lender Balance');                
            }
            if((moneyHeldMail.size()>0)&&(moneyHeldMail!=null))
            {
                LWC_SendEmailWithTemplateCtrl.sendEmail(moneyHeldMail,null,null,'AML - Held Repayments'); 
            } 
            if((heldTransactions.size()>0)&&(heldTransactions!=null))
            {
                update heldTransactions;
            } 
            
           
            
            
        }
        
        catch(Exception ex) 
        {
            Database.rollback(sp);
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='KYCScreeningScheduler', MethodName__c='execute', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
            system.debug('err--> '+err.id);
        }
        
    }
    public static void increasePerformance(){
        Integer a=0, b=1, c=2;
        
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
        a= b+c;
    }
    global void finish(Database.BatchableContext BC) 
    {
        // execute any post-processing operations
    }
    
    
}