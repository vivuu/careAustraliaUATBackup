global class LWC_SendFullyFundedEmail  implements Database.Batchable<sObject>
{
    global List<String> transIds=new List<String>();
    global LWC_SendFullyFundedEmail(List<String> transIds)
    {
        this.transIds=transIds;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        return Database.getQueryLocator([Select Id, Name, Lender__c,Lender_Email__c From Transaction__c Where id IN :transIds]);
    }
    
    global void execute(Database.BatchableContext BC, List<Transaction__c> transactions) 
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        try
        {
            for(Transaction__c trans: transactions)
            {
                OrgWideEmailAddress[] owea = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName=:Label.LWC_OrganizationWideEmailAddress];
                EmailTemplate template = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name ='Updated MAD216 Loan fully funded' LIMIT 1];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                System.debug('Sending from batch class');
                mail.setSaveAsActivity(false);
                mail.setTemplateId(template.Id);
                mail.setWhatId(trans.Id);
                mail.setTargetObjectId(trans.Lender__c);
                if(owea.size()>0){
                    mail.setOrgWideEmailAddressId(owea[0].Id);
                }else
                {
                    mail.setReplyTo('info@care.org.au');
                    mail.setSenderDisplayName('CARE Australia');
                }
                emails.add(mail);
            }
            try
            {
                Messaging.SendEmailResult[] results =Messaging.sendEmail(emails);
                System.debug('Results-->'+results);
            }
            catch(exception e)
            {
                System.debug('Errors found-->'+e.getMessage());
            }   
            
            
            
        }
        
        catch(Exception ex) 
        {
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_SendFullyFundedEmail', MethodName__c='execute',Exception_Type__c='Error', 
                                                        Description__c=ex.getMessage(),StackTrace__c=ex.getStackTraceString());
            insert err;
            system.debug('err--> '+err.id);
        }
        
    }
    global void finish(Database.BatchableContext BC) 
    {
        // execute any post-processing operations
    }
    
    
}