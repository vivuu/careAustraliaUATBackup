public without sharing class CareHomePageCtrl {
    public String hBody{GET;SET;}
    public CareHomePageCtrl(){
        String content = getContent('Why LWC');
        String contactId = ApexPages.currentPage().getParameters().get('ContactId'); 
        String transactionIds = ApexPages.currentPage().getParameters().get('TransactionIds');
        String template = ApexPages.currentPage().getParameters().get('Template');
        String relatedToId = ApexPages.currentPage().getParameters().get('relatedToId');
        system.debug('### contactId: '+contactId+' - '+relatedToId);
        if( contactId!=null && transactionIds!=null && template!=null && (relatedToId==null || relatedToId=='')){
            fillBody(contactId, transactionIds, template, '');
        } else if(relatedToId != null && transactionIds!=null && template!=null){
            fillBody(contactId, transactionIds, template, relatedToId);
        } else {
            hBody = 'Information is not correct';
        }
        
    }
    public void fillBody( String contactId, String tIds, String temp, String relatedToId){
        List<EmailTemplate> eTemplates = [SELECT Id, Name, DeveloperName, Body, HtmlValue from EmailTemplate WHERE Name = :temp];
        Map<String,Object> contactFieldMap = getContactFieldsRecordInfo(contactId);
        // Map<String,Object> oppFieldMap = getOpportunityFieldsRecordInfo(relatedToId);    Not in use for now
        System.debug( 'MAP:'+contactFieldMap );
        if(eTemplates.size() > 0){
            String hValue = eTemplates[0].HtmlValue;
            if(contactFieldMap!=null && !contactFieldMap.isEmpty() && relatedToId==''){
                for( String field : contactFieldMap.keySet() ){
                    if( hValue.containsIgnoreCase('{'+field+'}') ){
                        System.debug('FF:'+field+':'+(String)contactFieldMap.get(field));
                        String v = contactFieldMap.get(field)!=null? (String)contactFieldMap.get(field)+'' : '';
                        hValue = hValue.replaceAll( '\\{'+field+'\\}', v );
                    }
                }
            }
            
            /* if(relatedToId != ''){
if(oppFieldMap!=null && !oppFieldMap.isEmpty() && relatedToId != ''){
for( String field : oppFieldMap.keySet() ){
if( hValue.containsIgnoreCase('{'+field+'}') ){
System.debug('FF:'+field+':'+(String)oppFieldMap.get(field));
String v = oppFieldMap.get(field)!=null? (String)oppFieldMap.get(field)+'' : '';
hValue = hValue.replaceAll( '\\{'+field+'\\}', v );
}
}
}
} */
            System.debug('tids are-->'+tIds);
            String table = createTable( tIds );
            if( temp == 'LWC Donation PDF' && tIds.length()>0 && tIds!='' ){
                List<Id> transactionIds = tIds.split(',');
                List<Transaction__c> transactions = [SELECT Id, Opportunity__r.Name, Opportunity__r.Payee_Name__c FROM Transaction__c WHERE Id IN :transactionIds];
                if( transactions.size() > 0 && transactions[0].Opportunity__r!=null ){
                    String n = transactions[0].Opportunity__r.Name;
                    n = n.replaceAll('\\$','');
                    hValue = hValue.replaceAll( '\\{oppName\\}', n );
                } else{
                    hValue = hValue.replaceAll( '\\{oppName\\}', '' );
                }
            }
            if(relatedToId != '' && relatedToId != null){
                relatedToId = relatedToId.replaceAll('\\$','');
                hValue = hValue.replaceAll( '\\{Payee_Name__c\\}', relatedToId );
                /* List<Opportunity> opps = [SELECT Payee_Name__c FROM Opportunity WHERE Id = :relatedToId];
if( !opps.isEmpty() ){
String n = opps[0].Payee_Name__c;
n = n.replaceAll('\\$','');
hValue = hValue.replaceAll( '\\{Payee_Name__c\\}', n );
} */
            } else{
                String n = (String)contactFieldMap.get('name');
                n = n.replaceAll('\\$','');
                hValue = hValue.replaceAll( '\\{Payee_Name__c\\}', n );
            }
            hValue = hValue.replaceAll( '\\{EmbedTable\\}', table );
            System.debug('HVV:'+hValue);
            if( eTemplates.size()>0 ){
                hBody = hValue;
            }   
        } else{
            hBody = 'Template not found';
        }
    }
    String createTable( String tIds ){
        if( tIds.length()>0 && tIds!='' ){
            
            List<Id> transactionIds = tIds.split(',');
            System.debug('From create table-->'+transactionIds+'<---');
            List<Transaction__c> transactions = [SELECT Id, Type__c, Amount__c, Completed_Date__c FROM Transaction__c WHERE Id IN :transactionIds];
            String table = '<table style="width:100%"> <tr style="background-color:#E4761E; font-weight:bold"> <td style="color: white; text-align: center;">Date</td><td style="color: white;text-align: center;">Type</td><td style="color: white;text-align: center;">Amount</td></tr><tbody>';
            for( Transaction__c transactionD : transactions ){
                DateTime dT = transactionD.Completed_Date__c;
                if(dT==null)
                {
                    dT=System.now();   
                }
                table+='<tr><td style="color: #002A3A;text-align: center;">'+dT.year()+'-' +dT.month()+'-'+ dT.day()+'</td><td style="color: #002A3A;text-align: center;">'+transactionD.Type__c+'</td><td style="color: #002A3A;text-align: center;">'+transactionD.Amount__c+'</td></tr>';
            }
            table+='</tbody>';
            table+='</table>';
            System.debug('TABLE|||||'+table);
            return table;
        } else{
            return '';
        }
    }
    @AuraEnabled
    public static String getContent( String channelName ){
        String channelId = getChannelId(channelName);
        System.debug('channelId'+channelId);
        //get the image content
        ConnectApi.ManagedContentVersionCollection obj = 
            ConnectApi.ManagedContent.getAllContent(channelId, 0, 250, 'en_US', 
                                                    'CareAustraliaSite',false,
                                                    '2023-06-25T18:24:31.000Z','2024-06-25T18:24:31.000Z');
        return JSON.serialize(obj);
    }
    @AuraEnabled (cacheable=true)
    public static String getChannelId(String channelName){
        ConnectApi.ManagedContentChannelCollection channelRepObj = 
            ConnectApi.ManagedContent.getAllDeliveryChannels(0,6);        
        
        //loop through the channels and return the channel Id
        for(ConnectApi.ManagedContentChannel channelObj: channelRepObj.channels){
            if(channelObj.channelName == channelName){
                return channelObj.channelId;
            }
        }
        return null;
    }
    
    public class ReturnWrapper{
        String title {get;set;}
        String url {get;set;}
    }
    @AuraEnabled(cacheable=true)
    public static List <Lend_With_Care_Section__mdt> LWCSectionMetaData(String category){
        
        List <Lend_With_Care_Section__mdt> LWCSectionMetaData=[SELECT Category__c,Value_1__c,Value_2__c,MasterLabel FROM Lend_With_Care_Section__mdt where Category__c=:category ];
        
        return LWCSectionMetaData;
    }
    @AuraEnabled 
    public static String getPdfFileAsBase64String(String ContactId, String transactionIds, String template) {
        PageReference myPage = Page.TransactionPdfDownload;
        myPage.getParameters().put('ContactId', ContactId); // Set parameters if needed
        myPage.getParameters().put('TransactionIds', transactionIds); // Set parameters if needed
        myPage.getParameters().put('Template', template); // Set parameters if needed
        
        Blob pdfBlob;
        try {
            pdfBlob = myPage.getContentAsPDF();
        } catch(Exception ex) {
            // Handle exceptions if any error occurs during PDF generation
            System.debug('Error generating PDF: ' + ex.getMessage());
            return null;
        }
        
        // Convert Blob to Base64 string
        String pdfBase64 = EncodingUtil.base64Encode(pdfBlob);
        
        return pdfBase64;
    }
    
    @AuraEnabled 
    public static Map<String,Object> getContactFieldsRecordInfo(String contId) {
        String SobjectApiName = 'Contact';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        String fields = '';
        Map<String, Object> fieldValueMap = new Map<String, Object>();
        for(String fieldName : fieldMap.keyset() )
        {
            fields+=fieldName+',';
        }
        if( fields.length() > 1 ){
            fields = fields.substring(0, fields.length()-1);
            String query = 'SELECT '+fields+' FROM Contact WHERE Id = \''+contId+'\'';
            List<sObject> contacts = Database.query( query );
            if( contacts.size() > 0 ){
                sObject c = contacts[0];
                for( String field : fields.split(',') ){
                    fieldValueMap.put( field, c.get(field) );
                }
                return fieldValueMap;
            }
        }
        return null;
    }
    
    /* @AuraEnabled         Not in use
public static Map<String,Object> getOpportunityFieldsRecordInfo(String contId) {
String SobjectApiName = 'Opportunity';
Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
String fields = '';
Map<String, Object> fieldValueMap = new Map<String, Object>();
for(String fieldName : fieldMap.keyset() )
{
fields+=fieldName+',';
}
if( fields.length() > 1 ){
fields = fields.substring(0, fields.length()-1);
String query = 'SELECT '+fields+' FROM Opportunity WHERE Id = \''+contId+'\'';
List<sObject> contacts = Database.query( query );
if( contacts.size() > 0 ){
sObject c = contacts[0];
for( String field : fields.split(',') ){
fieldValueMap.put( field, c.get(field) );
}
return fieldValueMap;
}
}
return null;
} */    
}