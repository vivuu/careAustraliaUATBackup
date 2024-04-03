/**
* Name          :       LWC_SendEmailWithTemplateCtrl
* Author        :       Amit Goyal
* Date          :       08 October, 2023
* Description   :       Send EmailTemplate for LWC Related Events and Requirements
*/ 
global without sharing class LWC_SendEmailWithTemplateCtrl {
    WebService static void sendEmail(list<String> contactIds, String loanId, list<String> transIds, String eventType) {
        //list<String> contactIds = new list<String>{'0039D00000WOEDdQAP', '0039D00000WOC7dQAH', '0039D00000WOEkhQAH', '0039D00000SzulBQAR'};
        //LWC_SendEmailWithTemplateCtrl.sendEmail(contactIds, null, null, 'Loan Fully Funded');
        SavePoint sp = Database.setSavepoint();
        try{
            String strSoql = 'Select Id, Name, Lender__c,Lender_Email__c From Transaction__c Where Status__c=\'Completed\'';
            if(loanId != null && loanId.trim().length()>0){
                strSoql+=' AND Loan__c =: loanId';
            }
            if(transIds != null && transIds.size()>0){
                strSoql+=' AND Id IN: transIds';
            }
            String templateName='';
            if(eventType=='Thank you for Donation'){
                // LWC_TransactionTriggerHandler for Completed Donation which are not from Cart - Done
                templateName='MAD136 Thank you for donation';
                strSoql+=' AND Type__c = \'Donation\'';
            } else if(eventType=='Loan Fully Funded') {
                // Loan become active - LoanTriggerHandler - Done
                templateName='Updated MAD216 Loan fully funded';
                strSoql+=' AND Type__c = \'Loan\'';
            } else if(eventType=='Repayment Schedule Change') {
                // whenever lwc admin changes the repayment schedule - button on loan edit component - Sayan(Done)
                templateName='MAD218 Schedule change';
                strSoql+=' AND Type__c = \'Loan\'';
            } else if(eventType=='AML - Held Repayments') {
                // Call from 14EM and 26EM in case reaching the AML Check Limit - Sayan(Done)
                // implemented if amount is reaching to $5000
                templateName='MAD189 Held repayments';
            } else if(eventType=='Credit Lender Balance') {
                // call from 26EM if the AML Check passed and money is flowing - Sayan(Done)
                templateName='MAD153 Credit received in Lender Balance';
            } else if(eventType=='Successful withdrawal') {
                // LWC_TransactionTriggerHandler on Completed Withdrawl - Done
                templateName='MAD222 Successful withdrawal';
            } else if(eventType=='Thank you after transaction') {
                // used in LWC_CheckoutEmail for checkout
                templateName='MAD221 Thank you after transaction';
            } else if(eventType=='Welcome on Lender Registration') {
                // will be implemented in code - Gowsic(Done)
                templateName='MAD16 - Welcome email after Lender account created (classic)';
            } else if(eventType=='Missed repayment') {
                // Repayment Schedule - if skipped - need to be done
                //LWC_SendEmailWithTemplateCtrl.sendEmail(contactIds, 'a3jHz000002271oIAA', 'Welcome on Lender Registration');
                templateName='MAD217 Missed repayment';
                strSoql+=' AND Type__c = \'Loan\'';
                
            } else if(eventType=='Refusal to Lender on withdrawal') {
                // will be called from case management on refusal - need to be done
                //LWC_SendEmailWithTemplateCtrl.sendEmail(contactIds, '', 'Refusal to Lender on withdrawal');
                templateName='MAD140 Refusal to Lender on withdrawal (redundant - manual email)';
                
            } else if(eventType=='Loan Written Off') {
                // will be called from flow - Done
                templateName='MAD209 - Loan written off';
                strSoql+=' AND Type__c = \'Loan\'';
                
            } else {
                system.debug('### Wrong Event Type');
            }
            list<Transaction__c> transList=new list<Transaction__c>();
            list<String> transId=new list<String>();
            if(templateName=='Updated MAD216 Loan fully funded')
            {
                strSoql+=' AND Lender__c !=\'0039D00000WOB5SQAX\' AND Lender__r.Email!=null';
                transList = Database.Query(strSoql);
                if(transList != null && transList.size()>0)
                {
                    Map<String,Transaction__c> uniqueCont=new Map<String,Transaction__c>();
                    for(Transaction__c trans:transList)
                    {
                        if(uniqueCont.get(trans.Lender_Email__c)==null)
                        {
                              uniqueCont.put(trans.Lender_Email__c,trans);
                            	transId.add(trans.Id);
                        }
                    }
                    LWC_SendFullyFundedEmail fullyfunded=new LWC_SendFullyFundedEmail(transId);
                    Database.executeBatch(fullyfunded,5);
                   
                }
            }
            else
            {
                if(contactIds == null || contactIds.size()==0){
                    contactIds = new list<String>();
                    transList = Database.Query(strSoql);
                    if(transList != null && transList.size()>0){
                        for(Transaction__c trans: transList){
                            if(trans.Lender__c != null){
                                contactIds.add(trans.Lender__c);
                            }
                        }
                    }
                }
                
                if((contactIds != null && contactIds.size()>0) && templateName != ''){
                    OrgWideEmailAddress[] owea = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName=:Label.LWC_OrganizationWideEmailAddress];
                    EmailTemplate template = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name =: templateName LIMIT 1];
                    list<String> toAddresses = new list<String>();
                    list<Contact> contacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN: contactIds];
                    for (Contact con : contacts) {
                        if(con.Email != null){
                            toAddresses.add(con.Email);
                        }
                    }
                    
                    if(toAddresses != null && toAddresses.size()>0){
                        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setSaveAsActivity(false);
                        mail.setTemplateId(template.Id);
                        if(loanId != null && loanId.trim().length()>0){
                            mail.setWhatId(loanId);
                        }
                        mail.setTargetObjectId(contactIds[0]);
                        //mail.setToAddresses(toAddresses);
                        mail.setBccAddresses(toAddresses);
                        if(owea.size()>0){
                            //mail.setReplyTo(owea[0].Address);
                            //mail.setSenderDisplayName(owea[0].DisplayName);
                            mail.setOrgWideEmailAddressId(owea[0].Id);
                        }else{
                            mail.setReplyTo('info@care.org.au');
                            mail.setSenderDisplayName('CARE Australia');
                        }
                        emails.add(mail);
                        Messaging.sendEmail(emails);
                    }
                }
            }
            
        }catch(Exception ex){
            system.debug('### ex: '+ex+' - '+ex.getStackTraceString());
            Database.rollback(sp);
            System.debug('error--> '+ex.getMessage());
            LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_SendEmailWithTemplateCtrl', MethodName__c='sendEmail', 
                                                        Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                        StackTrace__c=ex.getStackTraceString());
            insert err;
        }
    }
    
    @InvocableMethod(label='Written Off Email Alert')
    public static void sendWrittenOffEmailAlert(list<String> loanIds){
        LWC_SendEmailWithTemplateCtrl.sendEmail(null, loanIds[0], null, 'Loan Written Off');
        
    }
    
}