/**
* @description   ContentDocumentLink Repository
* @testClass     REP_ContentDocumentLinkTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              30/09/2021         Created ContentDocumentLink Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_ContentDocumentLink extends FW_SobjectRep implements IREP_ContentDocumentLink{
    /**
    * @description method to search files related to a specific set of ids
    * @author Guilherme Charro | 29-09-2021 
    * @param leadIdsSet set of ids that will be used to search for the files
    * @return List<ContentDocumentLink> return the list of files found
    **/
    public List<ContentDocumentLink> getFilesOnLead(Set<Id> leadIdsSet){
        return [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :leadIdsSet];
    }
}