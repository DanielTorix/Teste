/**
@author Antonio Santos   
@date   11/08/2021
@description Test class for REP_Document
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Antonio Santos                11/08/2021           Original Version                         100
Hugo Rodrigues                16/11/2021         updated to meet US41246                    100
*/@isTest
public class REP_DocumentTest {
    @isTest
    static void documentTest() {
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

            REP_Document documentRepository = new REP_Document();


            Document doc = documentRepository.getDocumentByDeveloperName(testDoc.DeveloperName);
            List<Document> docs = documentRepository.getDocumentListByDeveloperName(new Set<String>{testDoc.DeveloperName});
            
            List<SObjectField> docFields = REP_Document.DOCUMENT_FIELDS;

            System.assert(doc != null);
            System.assert(docFields != null && !docFields.isEmpty());

            Test.stopTest();
        }
    }
}