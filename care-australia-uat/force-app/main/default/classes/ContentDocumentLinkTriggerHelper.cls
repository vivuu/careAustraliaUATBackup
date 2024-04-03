public class ContentDocumentLinkTriggerHelper {
    //Used to create ContentDistribution for ContentDocumentLink so that we have url to show on lwc site
    public static void handleContentDistribution( List<ContentDocumentLink> contentDocLinks ){
        Set<Id> contentDocumentIds = new Set<Id>();
        for( ContentDocumentLink cdL : contentDocLinks ){
            contentDocumentIds.add( cdL.ContentDocumentId );
        }
        List<ContentVersion> cvs = [SELECT Id, Title FROM ContentVersion WHERE contentDocumentId IN :contentDocumentIds];
        List<ContentDistribution> cds = new List<ContentDistribution>();
        for( ContentVersion cv : cvs ){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = cv.Title;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cds.add( cd );
        }
        if( !cds.isEmpty() ){
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.allowSave = false;
            Database.insert(cds, dml);
        }
    }
    public static void handleVisibility(List<ContentDocumentLink> contentDocLinks){
        for( ContentDocumentLink cdl : contentDocLinks ){
            cdl.Visibility = 'AllUsers';
        }
    }
}