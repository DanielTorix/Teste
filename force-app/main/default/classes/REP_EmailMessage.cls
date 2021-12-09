/**
* @description   Email Message Repository
* @testClass     REP_EmailMessageTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                06/07/2021          Created Case Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_EmailMessage extends FW_SobjectRep implements IREP_EmailMessage {
    public List<EmailMessage> getEmailMessagesById(List<Id> emailIdList){
        return [SELECT Id, RelatedToId, ParentCase__c FROM EmailMEssage WHERE Id IN:emailIdList];
    }
}