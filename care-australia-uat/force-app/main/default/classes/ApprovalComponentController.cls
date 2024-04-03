public class ApprovalComponentController {
    @AuraEnabled(cacheable=true)
    public static List<String> getPermissionSetDetails(Id userId) {
        List<String> userPermList=new List<String>();
        List<PermissionSetAssignment> permsets=[Select Id,PermissionSetId,PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE 
                                                   (PermissionSet.Name='LWC_Admin' OR PermissionSet.Name='LWC_Loan_Managers' OR PermissionSet.Name='LWC_Loan_Reviewers'
                                                    OR PermissionSet.Name='LWC_Programs_Manager' OR PermissionSet.Name='LWC_Finance_Manager' OR PermissionSet.Name='LWC_Content_Managers') 
                                                    AND IsActive=TRUE AND AssigneeId=: userId];
        if(permsets.size()>0)
        {
            for(PermissionSetAssignment p: permsets)
            {
                userPermList.add(p.PermissionSet.Name);
            }   
        }   
        return userPermList;
    }

}