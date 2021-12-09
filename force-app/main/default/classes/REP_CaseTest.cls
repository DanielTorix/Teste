/**
@author Guilherme Charro 
@date   16/06/2021
@description Test class for TW_Case_CloseChildCases
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro              16/06/2021          Original Version                         unknown
Hugo Rodrigues                15/09/2021            updated class                           100
*/
@isTest
public class REP_CaseTest {
	@isTest
    static void CaseTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Case> listCases = FW_TestDataFactory.createCase(2, true);
            listCases[1].ParentId = listCases[0].Id;
            update listCases;
            
            Set<Id> idCases = new Set<Id>();
            idCases.add(listCases[0].Id);
            
            test.startTest();
                Rep_Case caseRepository = new REP_Case();
                List<Case> isClosedCaseReturned = caseRepository.getChildCases(idCases);
                List<Case> casesWithChildReturned = caseRepository.getCaseWithChildCasesById(idCases);
                List<Case> parentCaseReturned = caseRepository.getParentCase(idCases);
                List<Case> casesReturned = caseRepository.getCasesById(idCases);
            test.stopTest();
            System.assertEquals(1, casesReturned.size());
            System.assertEquals(1, casesWithChildReturned.size());
            System.assertEquals(1, parentCaseReturned.size());
            System.assertEquals(1, isClosedCaseReturned.size());
        }
    }
}