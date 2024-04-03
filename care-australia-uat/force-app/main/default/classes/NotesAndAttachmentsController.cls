public with sharing class NotesAndAttachmentsController {
    @AuraEnabled(cacheable=true)
    public static Map<Id,String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT Id, VersionData, FileType, Title, FileExtension,
                                                    ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
                                                    CreatedDate, ContentDocumentId, ContentDocument.FileType 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        
        //return JSON.serialize(docs);
      Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }

     
    @AuraEnabled(cacheable=true)
    public static String getExperienceURL(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        baseURL =  baseURL.replace('/s/login', '');
        baseURL =  baseURL.replace('/s/Login', '');
        baseURL =  baseURL.replace('/login', '');
        baseURL =  baseURL.replace('/Login', '');
        return baseURL;
}
}