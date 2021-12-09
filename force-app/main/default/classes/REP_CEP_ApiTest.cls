/**
* @description    CEP Api Repository Test
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created CEP Api Repository Test
* ------------------------------------------------------------------------------------ 
*/
@isTest
public class REP_CEP_ApiTest {
    @isTest
    static void apiTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
        System.runAs(runningUser) {
            Test.startTest();

            REP_CEP_Api apiRepository = REP_CEP_Api.getInstance();

            CEP_ApiMethod__mdt method = apiRepository.getMethodByDeveloperName('TEST');
            CEP_ApiLogicalEnvironment__mdt logicalEnvironment = apiRepository.getLogicalEnvironmentByDeveloperName('Test');

            CEP_ApiPath__mdt path = apiRepository.getPathById(method.ApiPath__c);

            CEP_ApiCredential__mdt credential = apiRepository.getCredentialByEnvIdPathId(logicalEnvironment.Id, path.Id);
            
            List<CEP_ApiHttpHeader__mdt> httpHeaderList = apiRepository.getHttpHeaderByMethodId(method.Id);

            CEP_ApiSetting__c setting = apiRepository.getSetting();

            System.assert(method != null);
            System.assert(logicalEnvironment != null);
            System.assert(credential != null);
            System.assert(path != null);
            System.assert(httpHeaderList != null && !httpHeaderList.isEmpty());
            System.assert(setting != null);

            Test.stopTest();
        }
    }
}