/**
 * Created by mateuszbednarek on 18/02/2021.
 */

public without sharing class GDPRController {

    @AuraEnabled
    public static String getContentDocumentId(){
        ContentVersion ver = [SELECT Id, ContentDocumentId,Title FROM ContentVersion WHERE Title ='OMV GDPR' AND
        IsLatest = true];
        return JSON.serialize(ver);
    }

    @AuraEnabled
    public static Boolean showGDPR(){
        return [SELECT Id FROM AuthorizationFormConsent WHERE Status = 'Signed' AND ConsentGiverId =: UserInfo.getUserId()].isEmpty();
    }

    @AuraEnabled
    public static String updateGDPRConsent(String contentDocumentId){
        AuthorizationFormText txt = [SELECT Id FROM AuthorizationFormText WHERE ContentDocumentId =: contentDocumentId];
        AuthorizationFormConsent consent = new AuthorizationFormConsent(
                Status ='Signed',
                ConsentGiverId = UserInfo.getUserId(),
                Name = UserInfo.getName() +' - GDPR Privacy Policy (Portal)',
                ConsentCapturedSource = 'OMV Customer Portal',
                ConsentCapturedSourceType = 'Web',
                ConsentCapturedDateTime = System.now(),
                AuthorizationFormTextId = txt.Id
        );

        try{
            insert consent;
        }catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return 'OK';
    }

}