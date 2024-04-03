public class UserTriggerHelper {
	@future
    public static void assginPermissionSet(Set<Id> userId){
        PermissionSet ps = [SELECT Id, NAME FROM PermissionSet WHERE Name = 'SMS_App_Permission_Set_Community'];
        List<PermissionSetAssignment> psaList = new LIst<PermissionSetAssignment>();
        if(ps != null){
            for(User u: [SELECT Id, Name FROM User WHERE Id IN: userId AND ContactId != null]){
                PermissionSetAssignment psa = new PermissionSetAssignment();
                psa.AssigneeId = u.Id;
                psa.PermissionSetId = ps.Id;
                psaList.add(psa);
        	}
            if(!psaList.isEmpty()){
                insert psaList;
            } 
        }

    }
}