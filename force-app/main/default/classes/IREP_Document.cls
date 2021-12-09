/**
* @description   Interface for the Document Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos                  09/08/2021          Interface for the Document Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Document extends FW_ISObjectRep {
    Document getDocumentByDeveloperName(String documentDeveloperName);
    List<Document> getDocumentListByDeveloperName(Set<String> documentDeveloperName);
}