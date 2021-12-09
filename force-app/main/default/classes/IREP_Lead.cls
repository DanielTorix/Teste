/**
* @description   Lead interface
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              28/09/2021         Created Lead interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Lead extends FW_ISObjectRep{
    List<Lead> getLeadNotConvertedByUserID(Set<ID> userID);
    String getLeadsByOwnerIdAndStatuses(Set<Id> userIds, List<String> leadStatuses);
}