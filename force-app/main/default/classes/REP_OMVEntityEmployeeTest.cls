/**
@author Hugo Rodrigues  
@date   20/10/2021 
@description Test class for REP_OMVEntityEmployee
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               20/10/2021           Original Version                         100
*/
@isTest
public class REP_OMVEntityEmployeeTest {
	@isTest
    static void OMVEntityEmployeeTest(){
        List<User> runningUserList = FW_TestDataFactory.createUsers(3, true, 'System Administrator', null);
        System.runAs(runningUserList[0]){  
            List<CompanyCode__c> companyCodeList = FW_TestDataFactory.createCompanyCode(1, true);
            List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>{
                new OMVEntityEmployee__c(
                    EmployeeUser__c=runningUserList[0].Id,
                    OMVEntity__c=companyCodeList[0].Id
                ),
                new OMVEntityEmployee__c(
                    EmployeeUser__c=runningUserList[1].Id,
                    OMVEntity__c=companyCodeList[0].Id
                ),
                new OMVEntityEmployee__c(
                    EmployeeUser__c=runningUserList[2].Id,
                    OMVEntity__c=companyCodeList[0].Id
                )
            };
            insert oMVEntityEmployeeList;
            Set<ID> userIdSet = new Set<ID>{
                runningUserList[0].Id,
                runningUserList[1].Id,
                runningUserList[2].Id
            };
            test.startTest();
            REP_OMVEntityEmployee oMVEntityEmployeeRepository = new REP_OMVEntityEmployee();
                List<OMVEntityEmployee__c> OMVEntityEmployeeReturned = oMVEntityEmployeeRepository.getCompanyCodeByUserID(userIdSet);
            test.stopTest();
            System.assertEquals(3, OMVEntityEmployeeReturned.size());
        }
    }
}