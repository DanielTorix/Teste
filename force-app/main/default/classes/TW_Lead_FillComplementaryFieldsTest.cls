/**
@author Guilherme Charro 
@date   08/09/2021 
@description Test class for TW_OMVEntityEmployee_UpdateUniqueID
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro              08/09/2021            Original Version                         100
Hugo Rodrigues                20/10/2021            US39484 update                           100
Hugo Rodrigues                27/10/2021            Added new Lead with Owner Group          100

*/
@isTest
public with sharing class TW_Lead_FillComplementaryFieldsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void fillComplementaryFieldsTest() {
        IREP_CompanyCode companyCodeRepository = (REP_CompanyCode)mocks.mock(REP_CompanyCode.class);
        IREP_OMVEntityEmployee oMVEntityRepository = (REP_OMVEntityEmployee)mocks.mock(REP_OMVEntityEmployee.class);
        List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>();
       
        List<CompanyCode__c> companyCodeList = new List<CompanyCode__c>{
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
                Country__c = 'RO'
            ),
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
                Country__c = 'AT'
            )
        };
        oMVEntityEmployeeList.add(
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=fflib_IDGenerator.generate(User.sObjectType),
                OMVEntity__c=companyCodeList[0].Id
            )
        );
        List<Lead> leadList = new List<Lead>{
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                CompanyCode__c = companyCodeList[0].Id,
                OwnerId=oMVEntityEmployeeList[0].EmployeeUser__c
            ),
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                CompanyCode__c = companyCodeList[1].Id,
                OwnerId=fflib_IDGenerator.generate(User.sObjectType)
            ),
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                OwnerId=fflib_IDGenerator.generate(User.sObjectType)
            ),
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                OwnerId=fflib_IDGenerator.generate(Group.sObjectType)
            )       
        };

        leadList[0] = (Lead)fflib_ApexMocksUtils.setReadOnlyFields(
            leadList[0],
            Lead.class,
            new Map<SObjectField, Object> {Lead.RecordTypeId => DO_Lead.LEAD_RECORDTYPEID_CEPCARDS}
        );
        leadList[0] = (Lead)fflib_ApexMocksUtils.setReadOnlyFields(
            leadList[0],
            Lead.class,
            new Map<SObjectField, Object> {Lead.RecordTypeId => DO_Lead.LEAD_RECORDTYPEID_CEPCARDS}
        );

        Map<Id,Lead> oldLeadMap = new Map<Id,Lead>();
        oldLeadMap.put(leadList[0].Id, leadList[1]);
        oldLeadMap.put(leadList[1].Id, leadList[0]);
        oldLeadMap.put(leadList[2].Id, leadList[2]);
        oldLeadMap.put(leadList[3].Id, leadList[3]);

        mocks.startStubbing();
        mocks.when(companyCodeRepository.getCompanyCodeInfo((Set<Id>) fflib_match.anyObject())).thenReturn(companyCodeList);
        mocks.when(oMVEntityRepository.getCompanyCodeByUserID((Set<Id>) fflib_match.anyObject())).thenReturn(oMVEntityEmployeeList);
        mocks.stopStubbing();

        TW_Lead_FillComplementaryFields jobExecutionWorker = new TW_Lead_FillComplementaryFields();
        jobExecutionWorker = new TW_Lead_FillComplementaryFields(companyCodeRepository,oMVEntityRepository);
        
        jobExecutionWorker.execute(leadList, null);
        jobExecutionWorker.execute(leadList, oldLeadMap);

        ((IREP_CompanyCode)mocks.verify(companyCodeRepository, 2)).getCompanyCodeInfo((Set<Id>) fflib_match.anyObject());
        ((IREP_OMVEntityEmployee)mocks.verify(oMVEntityRepository, 2)).getCompanyCodeByUserID((Set<Id>) fflib_match.anyObject());
    }
}