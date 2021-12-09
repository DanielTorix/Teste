/**
    * @description   Interface for DML operations
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_ISObjectRep {

    List<Database.SaveResult> insertSObjects(List<SObject> sObjectList);
    List<Database.SaveResult> updateSObjects(List<SObject> sObjectList);
    List<Database.UpsertResult> upsertSObjects(List<SObject> sObjectList);
    List<Database.UpsertResult> upsertSObjects(List<SObject> sobjectList, SObjectField externalIdField);
    List<Database.DeleteResult> deleteSObjects(List<SObject> sObjectList);
    void setAllOrNone(Boolean value);

}