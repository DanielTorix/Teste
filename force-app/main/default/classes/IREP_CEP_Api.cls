/**
* @description   Interface for CEP Api Repository
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created CEP Api Repository interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_CEP_Api extends FW_ISObjectRep {
    CEP_ApiMethod__mdt getMethodByDeveloperName(String developerName);
    CEP_ApiLogicalEnvironment__mdt getLogicalEnvironmentByDeveloperName(String developerName);
    CEP_ApiCredential__mdt getCredentialByEnvIdPathId(Id logicalEnvironmentId, Id pathId);
    CEP_ApiPath__mdt getPathById(Id pathId);
    List<CEP_ApiHttpHeader__mdt> getHttpHeaderByMethodId(Id methodId);
    CEP_ApiSetting__c getSetting();
}