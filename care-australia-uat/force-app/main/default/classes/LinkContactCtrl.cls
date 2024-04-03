public class LinkContactCtrl {
    @AuraEnabled (cacheable= true)
    public static List <Contact> getContactsForCase(String recordId){
        if(recordId != null && recordId.trim().length()>0){
            list<Case> csList = [Select Id, ContactEmail, SuppliedEmail, ContactId From Case Where Id =: recordId limit 1];
            if(csList != null && csList.size()>0){
                if(csList[0].SuppliedEmail != null){
                    List <Contact> conlist = [Select Id,Salutation, Name, Email From Contact Where Email =: csList[0].SuppliedEmail];
                    return conlist;
                }
            }
        }
        return null;
    }
    
    @AuraEnabled (cacheable= true)
    public static List<SObject> getContactsForTask(String recordId){
        if(recordId != null && recordId.trim().length()>0){
            Task tk = [select Id,CallerPhone__c ,Who.Name from Task where Id =:recordId];
            if(tk.CallerPhone__c != null){
                String fieldValue = tk.CallerPhone__c;
                System.debug('###Task Caller phone:'+fieldValue);
                List<List<SObject>> searchList = [FIND :fieldValue IN Phone FIELDS RETURNING Contact(Id,Salutation, Name,Phone,Email)];
                system.debug('search list'+searchList[0]);
                return searchList[0];
            }
        }
        return null;
    }
    
    @AuraEnabled 
    public static List<Task> updatetask(String taskId, String contactId ){
        List<Task> updatedtasks = new List<Task>();
        if(taskId != null){
            updatedtasks.add(new Task(Id = taskId, WhoId = contactId));
        }
        
        if(!updatedtasks.isEmpty()){
            system.debug('###Updated task'+updatedtasks);
            update updatedtasks;
            return updatedtasks;
        }
        return null;
    }   
    
}