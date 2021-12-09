/**
* @description   Document Repository
* @testClass     REP_Document
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos                  09/08//2021         Created the Document Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_Document extends FW_SobjectRep implements IREP_Document {
    public static final List<SObjectField> DOCUMENT_FIELDS = new SObjectField[] {
        Document.Id,
        Document.DeveloperName
    };
    
    public Document getDocumentByDeveloperName(String documentDeveloperName) {
        return [SELECT Id, DeveloperName FROM Document WHERE DeveloperName = :documentDeveloperName LIMIT 1];
    }
    public List<Document> getDocumentListByDeveloperName(Set<String> documentDeveloperName) {
        return [SELECT Id, DeveloperName FROM Document WHERE DeveloperName =:documentDeveloperName];
    }
}