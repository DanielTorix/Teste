/**
* @description   Lead Repository
* @testClass     REP_LeadTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              28/09/2021         Created Lead Repository
* Hugo Rodrigues                04/11/2021         added getLeadByUserID
* ------------------------------------------------------------------------------------ 
*/
public class REP_Lead extends FW_SobjectRep implements IREP_Lead{
    public static final List<SObjectField> LEAD_FIELDS = new SObjectField[] {
        Lead.Id,
        Lead.Name,
        Lead.GeneralGDPR__c,
        Lead.CompanyCode__c,
        Lead.isConverted,
        Lead.OwnerID,
        Lead.Status

    };

    public List<Lead> getLeadNotConvertedByUserID(Set<ID> userID) {

        return [SELECT Id, OwnerId,CompanyCode__c,isConverted FROM Lead Where OwnerId =: userID And isConverted = false];
    }
    public String getLeadsByOwnerIdAndStatuses(Set<Id> userIds, List<String> leadStatuses){
        return 'Select Id, CompanyCode__c, OwnerId From Lead Where OwnerId =: userIds AND Status IN:leadStatuses ';
    }
}