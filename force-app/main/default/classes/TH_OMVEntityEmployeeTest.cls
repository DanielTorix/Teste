/**
@author Hugo Rodrigues  
@date   20/10/2021 
@description Test class for TH_OMVEntityEmployee
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               20/10/2021           Original Version                         100
*/
@isTest
public class TH_OMVEntityEmployeeTest {
    @isTest
    static void OMVEntityEmployeeTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){        
            List<CompanyCode__c> companyCodeList = FW_TestDataFactory.createCompanyCode(1, true);
            List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>();    
            oMVEntityEmployeeList.add(
                new OMVEntityEmployee__c(
                    EmployeeUser__c=runningUser.Id,
                    OMVEntity__c=companyCodeList[0].Id
                )
            );
            test.startTest();
            insert oMVEntityEmployeeList;
            oMVEntityEmployeeList[0].CurrencyIsoCode='EUR';
            update oMVEntityEmployeeList;
            test.stopTest();
            System.assertNotEquals(null, oMVEntityEmployeeList[0].Id);
        }
    }
}