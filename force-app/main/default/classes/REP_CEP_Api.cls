/**
* @description    CEP Api Repository
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created CEP Api Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_CEP_Api extends FW_SobjectRep implements IREP_CEP_Api {
    public static Map<Id,CEP_ApiLogicalEnvironment__mdt> logicalEnvironmentMap;
    public static Map<String,Id> logicalEnvironmentDevNameMap;

    public static Map<Id,CEP_ApiCredential__mdt> credentialMap;
    public static Map<String,Id> credentialEnvIdPathIdMap;

    public static Map<Id,CEP_ApiPath__mdt> pathMap;
    public static Map<Id,CEP_ApiMethod__mdt> methodMap;

    public static Map<String,Id> methodDevNameMap;

    public static Map<Id,CEP_ApiHttpHeader__mdt> httpHeaderMap;
    public static Map<Id,List<Id>> httpHeaderMethodIdMap;

    public static REP_CEP_Api repositoryInstance;

    public static CEP_ApiSetting__c apiSetting;

    public static REP_CEP_Api getInstance() {
        if (repositoryInstance == null) {
            repositoryInstance = new REP_CEP_Api();

            logicalEnvironmentMap = new Map<Id,CEP_ApiLogicalEnvironment__mdt>(
                [
                    SELECT Id, Label, DeveloperName FROM CEP_ApiLogicalEnvironment__mdt
                ]
            );

            logicalEnvironmentDevNameMap = new Map<String,Id>();

            for (CEP_ApiLogicalEnvironment__mdt logicalEnvironment : logicalEnvironmentMap.values()) {
                logicalEnvironmentDevNameMap.put(logicalEnvironment.DeveloperName, logicalEnvironment.Id);
            }

            credentialMap = new Map<Id,CEP_ApiCredential__mdt>(
                [
                    SELECT Id, ApiLogicalEnvironment__c, ApiPath__c, NamedCredential__c FROM CEP_ApiCredential__mdt
                ]
            );
            credentialEnvIdPathIdMap = new Map<String,Id>();

            for (CEP_ApiCredential__mdt credential : credentialMap.values()) {
                credentialEnvIdPathIdMap.put(credential.ApiLogicalEnvironment__c + ';' + credential.ApiPath__c, credential.Id);
            }

            pathMap = new Map<Id,CEP_ApiPath__mdt>(
                [
                    SELECT Id, Label, Path__c FROM CEP_ApiPath__mdt
                ]
            );

            methodMap = new Map<Id,CEP_ApiMethod__mdt>(
                [
                    SELECT Id, Label, DeveloperName, ApiPath__c, ContentType__c, HttpMethod__c, Input__c, MockOutput__c, OutputDeserializeClassName__c, SubPath__c, TimeoutOverride__c FROM CEP_ApiMethod__mdt
                ]
            );

            methodDevNameMap = new Map<String,Id>();

            for (CEP_ApiMethod__mdt method : methodMap.values()) {
                methodDevNameMap.put(method.DeveloperName, method.Id);
            }

            httpHeaderMap = new Map<Id,CEP_ApiHttpHeader__mdt>(
                [
                    SELECT Id, ApiMethod__c, HeaderName__c, HeaderValue__c FROM CEP_ApiHttpHeader__mdt
                ]
            );

            httpHeaderMethodIdMap = new Map<Id,List<Id>>();

            for (CEP_ApiHttpHeader__mdt header : httpHeaderMap.values()) {
                if (!httpHeaderMethodIdMap.containsKey(header.ApiMethod__c)) {
                    httpHeaderMethodIdMap.put(header.ApiMethod__c, new List<Id>());
                }

                httpHeaderMethodIdMap.get(header.ApiMethod__c).add(header.Id);
            }

            apiSetting = CEP_ApiSetting__c.getInstance();
        }

        return repositoryInstance;
    }

    public CEP_ApiMethod__mdt getMethodByDeveloperName(String developerName) {
        Id methodId = methodDevNameMap.get(developerName);

        if (methodId != null) {
            return methodMap.get(methodId);
        } else {
            return null;
        }
    }

    public CEP_ApiLogicalEnvironment__mdt getLogicalEnvironmentByDeveloperName(String developerName) {
        Id logicalEnvironmentId = logicalEnvironmentDevNameMap.get(developerName);

        if (logicalEnvironmentId != null) {
            return logicalEnvironmentMap.get(logicalEnvironmentId);
        } else {
            return null;
        }
    }

    public CEP_ApiCredential__mdt getCredentialByEnvIdPathId(Id logicalEnvironmentId, Id pathId) {
        Id credentialId = credentialEnvIdPathIdMap.get(logicalEnvironmentId + ';' + pathId);

        if (credentialId != null) {
            return credentialMap.get(credentialId);
        } else {
            return null;
        }
    }

    public CEP_ApiPath__mdt getPathById(Id pathId) {
        return pathMap.get(pathId);
    }

    public List<CEP_ApiHttpHeader__mdt> getHttpHeaderByMethodId(Id methodId) {
        List<Id> httpHeaderIdList = httpHeaderMethodIdMap.get(methodId);
        List<CEP_ApiHttpHeader__mdt> resultList = new List<CEP_ApiHttpHeader__mdt>();

        if (httpHeaderIdList != null) {
            for (Id httpHeaderId : httpHeaderIdList) {
                resultList.add(httpHeaderMap.get(httpHeaderId));
            }

            return resultList;
        } else {
            return null;
        }
    }

    public CEP_ApiSetting__c getSetting() {
        return apiSetting;
    }
}