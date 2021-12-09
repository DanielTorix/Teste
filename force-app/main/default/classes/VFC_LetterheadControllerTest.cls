/**
@author Antonio Santos   
@date   11/08/2021
@description Test class for VFC_LetterheadController
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Antonio Santos                11/08/2021           Original Version                         unknown
Hugo Rodrigues                15/11/2021         updated to meet US41246                    88
*/
@isTest
public class VFC_LetterheadControllerTest {
    @isTest
    public static void testController() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
        System.runAs(runningUser) {
            Folder folder = [SELECT Id FROM Folder WHERE DeveloperName = 'Experiences_Shared_Document_Folder' LIMIT 1];

            System.assert(folder != null);
            
            Document testDoc = new Document(
                Name = 'TESTDOC',
                DeveloperName = 'TESTDOC',
                FolderId = folder.Id
            );

            insert testDoc;

            Test.startTest();
            VFC_LetterheadController ctrl = new VFC_LetterheadController();
            ctrl.customerCountry='TE';
            Test.stopTest();
        }
    }
}