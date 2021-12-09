/**
 * Created by mateuszbednarek on 23/02/2021.
 */

@isTest
public with sharing class GDPRControllerTest {

    @TestSetup
    public static void testSetup(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = new User(FirstName = 'Test', LastName = 'User', Sales_Representative__c = '4321', ProfileId = p.Id, EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorgOmvTest.com', Email='Test@user' +
                        '.com', Alias = 'usr');
        insert usr;

        ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'OMV GDPR',
                PathOnClient = 'OMV_GDPR.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
        );
        insert contentVersion_1;
    }

    @IsTest
    public static void getDocumentId(){
        Id contentId = [SELECT Id,ContentDocumentId FROM ContentVersion].Id;
        String contentVersion = '';

        Test.startTest();
        contentVersion = GDPRController.getContentDocumentId();
        Test.stopTest();

        System.assertNotEquals('', contentVersion);
        System.assert(contentVersion.containsIgnoreCase('OMV GDPR'));
        System.assert(contentVersion.containsIgnoreCase(contentId));
    }

    @IsTest
    public static void testShowGDPR(){
        User u = [SELECT ID FROM User WHERE  FirstName = 'Test'];

        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion].ContentDocumentId;

        AuthorizationForm form = new AuthorizationForm(
                Name = 'GDPR Form',
                EffectiveFromDate = Date.today().addYears(-1),
                EffectiveToDate = Date.today().addYears(1)
        );

        insert form;

        AuthorizationFormText formText = new AuthorizationFormText(
                Name = 'GDPR Form Text',
                AuthorizationFormId = form.Id,
                ContentDocumentId = contentDocumentId
        );

        insert formText;


        System.runAs(u){
            Test.startTest();
            System.assert(GDPRController.showGDPR());
            GDPRController.updateGDPRConsent(contentDocumentId);
            System.assertNotEquals(true, GDPRController.showGDPR());
            Test.stopTest();
        }


    }


}