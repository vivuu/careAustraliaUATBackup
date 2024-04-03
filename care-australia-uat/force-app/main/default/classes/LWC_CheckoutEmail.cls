public without sharing class LWC_CheckoutEmail {
    public static void sendCheckoutEmail(set<String> lenderEmails){
        /*list<Transaction__c> transList = [Select Id, Lender__c, Lender__r.Email, Lender_Email__c 
                                          From Transaction__c 
                                          Where Id='a3mHz000000EgbwIAC' 
                                          AND Added_To_Cart__c=true];
        set<String> lenderEmails = new set<String>();
       	for(Transaction__c trans: transList){
            if(trans.Lender_Email__c != null && trans.Lender_Email__c.trim().length()>2){
                lenderEmails.add(trans.Lender_Email__c);
            }
            
            if(trans.Lender__r.Email != null && trans.Lender__r.Email.trim().length()>2){
                lenderEmails.add(trans.Lender__r.Email);
            }
        }*/
		system.debug('### lenderEmails: '+lenderEmails.size());
        system.debug('### lenderEmails: '+lenderEmails);
        DateTime dt = DateTime.Now().addMinutes(-5);
            //System.Now().addDays(-5);
        list<Transaction__c> transctions = [Select Id, Name, Lender__c, Lender__r.Email, Lender__r.Title,
                                            Lender__r.npe01__home_address__c ,Lender__r.FirstName, 
                                            Lender__r.LastName, Lender_Email__c, Opportunity__c, Opportunity__r.Payee_Name__c
                                            From Transaction__c 
                                            Where Status__c='Completed' AND Type__c != 'Payment'
                                            AND Added_To_Cart__c=true
                                            AND (Lender__r.Email IN: lenderEmails OR Lender_Email__c IN: lenderEmails)
                                           AND (Completed_Date__c >=: dt OR LastModifiedDate >=: dt)];
        system.debug('### transctions: '+transctions.size());
        map<String, list<Transaction__c>> lenderTransactionMap = new map<String, list<Transaction__c>>();
        String relatedToId='';
        for(Transaction__c t : transctions){
            if(relatedToId=='' && t.Opportunity__c != null){
                relatedToId=t.Opportunity__r.Payee_Name__c;
            }
            
            String emailTxt='';
            /*if(t.Lender__c != null && t.Lender__r.Email != null && t.Lender__r.Email.trim().length()>2){
                emailTxt=t.Lender__r.Email;
            }*/
            
            if(t.Lender_Email__c != null && t.Lender_Email__c.trim().length()>2){
                emailTxt=t.Lender_Email__c;
            }
            list<Transaction__c> result = lenderTransactionMap.get(emailTxt);
            if(result==null){
                result = new list<Transaction__c>();
            }
            result.add(t);
            
            if(emailTxt != null && emailTxt.trim().length()>0){
        		lenderTransactionMap.put(emailTxt, result);
            }
        }
        
        system.debug('### lenderTransactionMap: '+lenderTransactionMap.size());
        system.debug('### lenderTransactionMap: '+lenderTransactionMap.keyset());
        String templateName='MAD221 Thank you after transaction';
        EmailTemplate template = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name =: templateName LIMIT 1];
        for(String key: lenderTransactionMap.keyset()){
            //String strBody= '<table>';
            list<Transaction__c> result = lenderTransactionMap.get(key);
            map<String, Transaction__c> transctionsMap = new map<String, Transaction__c>(result);
            list<String> transIdsList = new list<String>();
            transIdsList.addAll(transctionsMap.keyset());
            String transIds = String.join(transIdsList, ',');
            system.debug('### transIds:'+transIds);
            
            if(relatedToId != null && relatedToId.trim().length()>0){
                getPdfFileAsBase64String(result[0].Lender__c, transIds, 'LWC Transaction PDF', template.Id, key, relatedToId);
            }else{
                system.debug('### No Opportunity Found.');
            }
        }
    }
    
     public static void getPdfFileAsBase64String(String contactId, String transactionIds, String template, String templateId, String emailId, String relatedToId) {
        PageReference myPage = Page.TransactionPdfDownload;
         System.debug('ContactId-->'+contactId);
         System.debug('transactionIds-->'+transactionIds);
         System.debug('template-->'+template);
         System.debug('templateId-->'+templateId);
         //emailId='crekuveipeifa-3141@yopmail.com';
         System.debug('emailId-->'+emailId);
         System.debug('relatedToId-->'+relatedToId);         
        myPage.getParameters().put('ContactId', contactId); // Set parameters if needed
        myPage.getParameters().put('TransactionIds', transactionIds); // Set parameters if needed
        myPage.getParameters().put('Template', template); // Set parameters if needed
		myPage.getParameters().put('relatedToId', relatedToId); // Set parameters if needed
         Blob pdfBlob;
         Blob b;
         try {
             if(!Test.isRunningTest()){
                 pdfBlob = myPage.getContentAsPDF();
                 b=myPage.getContent();
             }else{
                 pdfBlob=Blob.valueOf('test');
                 b=Blob.valueOf('test');
             }
             OrgWideEmailAddress[] owea = [select Id, DisplayName, Address from OrgWideEmailAddress where DisplayName=:Label.LWC_OrganizationWideEmailAddress];
             List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
             Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
             attach.setFileName('TransactionPdfDownload.pdf');
             attach.setBody(b);
             
             if(emailId != null){
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 mail.setSaveAsActivity(false);
                 mail.setTemplateId(templateId);
                 if(relatedToId != null && relatedToId.trim().length()>0){
                     mail.setWhatId(relatedToId);
                 }
                 
                 if(contactId != null && contactId.trim().length()>0){
                 	mail.setTargetObjectId(contactId);
                 }
                 List<string> toAddress = new List<string>();
                 toAddress.add(emailId);
                 //toAddress.add('amitgoyal09@gmail.com');
                 mail.setToAddresses(toAddress);
                 if(owea.size()>0){
                     //mail.setReplyTo(owea[0].Address);
                     //mail.setSenderDisplayName(owea[0].DisplayName);
                     mail.setOrgWideEmailAddressId(owea[0].Id);
                 }else{
                     mail.setReplyTo('info@care.org.au');
                     mail.setSenderDisplayName('CARE Australia');
                 }
                 mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
                 //mail.setSubject('LendWithCare - Successful Checkout & Receipt' );
                 //mail.setHtmlBody(emailBody);
                 System.debug('SEDING MAIL::'+mail);
                 emails.add(mail);
                 Messaging.sendEmail(emails);
             }
         } catch(Exception ex) {
             System.debug('Error generating PDF:'+ex.getMessage());
             LWC_Error_Log__c err = new LWC_Error_Log__c(Class_Name__c='LWC_SendEmailWithTemplateCtrl', MethodName__c='sendEmail', 
                                                         Exception_Type__c='Error', Description__c=ex.getMessage(), 
                                                         StackTrace__c=ex.getStackTraceString());
             insert err;
             //return null;
         }
        
        //String pdfBase64 = EncodingUtil.base64Encode(pdfBlob);
        //return pdfBase64;
        //return null;
    }
}