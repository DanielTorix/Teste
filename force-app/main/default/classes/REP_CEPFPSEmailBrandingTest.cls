/**
@author Hugo Rodrigues 
@date   16/11/2021 
@description Test class for REP_CEPFPSEmailBranding
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues                16/11/2021            Original Version                         100
*/
@isTest
public class  REP_CEPFPSEmailBrandingTest {
    @isTest
    static void cEPFPSEmailBrandingTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
        System.runAs(runningUser) {

            Test.startTest();
            REP_CEPFPSEmailBranding metadataRepository = new REP_CEPFPSEmailBranding();
            CEPFPSEmailBranding__mdt metadataobj = metadataRepository.getCEPFPSEmailBranding('TE');
            Test.stopTest();
        }
    }
}