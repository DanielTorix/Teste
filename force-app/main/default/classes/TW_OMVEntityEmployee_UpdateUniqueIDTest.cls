/**
@author Hugo Rodrigues  
@date   20/10/2021 
@description Test class for TW_OMVEntityEmployee_UpdateUniqueID
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               20/10/2021           Original Version                         100
*/
@isTest
public with sharing class TW_OMVEntityEmployee_UpdateUniqueIDTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void updateUniqueIDTest() {
        IREP_OMVEntityEmployee oMVEntityRepository = (REP_OMVEntityEmployee)mocks.mock(REP_OMVEntityEmployee.class);
        FW_IREP_BatchDefinition batchDefRep = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IREP_BatchDefinition batchDefRep2 = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IDO_JobExecution jobExecutionDO = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);

        List<CompanyCode__c> companyCodeList = new  List<CompanyCode__c>();
        Map<ID,OMVEntityEmployee__c> oMVEntityEmployeeMap = new Map<ID,OMVEntityEmployee__c>();
        
        Set<Id> omvEntityIdSet = new Set<Id>();
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'EmployeeEntityUpdate', 
                Class_Name__c = 'Async_EmployeeEntityUpdate',
                Job_Size__c = 200, 
                SObject_API_Name__c = 'Lead'
            )
        };
        
        //Create Parameters 
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'OwnerIDFromLead',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = String.valueOf(fflib_IDGenerator.generate(User.sObjectType))
            ),
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Status',
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Value__c = 'New,Working'
            )
        };


        //Create JobExecution
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };
        companyCodeList.add(new CompanyCode__c(
            Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
            Name = 'teste',
            Language__c = 'EN'
        ));
        List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>{
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=null,
                OMVEntity__c=companyCodeList[0].Id
            ),
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=fflib_IDGenerator.generate(User.sObjectType),
                OMVEntity__c=companyCodeList[0].Id
            ),
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=fflib_IDGenerator.generate(User.sObjectType),
                OMVEntity__c=companyCodeList[0].Id
            )
        };
        List<OMVEntityEmployee__c> oMVEntityEmployeeList2 = new  List<OMVEntityEmployee__c>{
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=oMVEntityEmployeeList[2].EmployeeUser__c,
                OMVEntity__c=companyCodeList[0].Id
            )
        };
        oMVEntityEmployeeMap.put(oMVEntityEmployeeList[1].Id,
             new OMVEntityEmployee__c(
                Id = oMVEntityEmployeeList[1].Id,
                EmployeeUser__c = oMVEntityEmployeeList[1].EmployeeUser__c
            )
        );
        oMVEntityEmployeeMap.put(oMVEntityEmployeeList[2].Id,
             new OMVEntityEmployee__c(
                Id = oMVEntityEmployeeList[2].Id,
                EmployeeUser__c = oMVEntityEmployeeList[2].EmployeeUser__c
            )
        );
        omvEntityIdSet.add(oMVEntityEmployeeList2[0].Id);
        mocks.startStubbing();
        mocks.when(oMVEntityRepository.getCompanyCodeByUserID((Set<Id>) fflib_match.anyObject())).thenReturn(oMVEntityEmployeeList2);
        mocks.when(batchDefRep.getBatchDefinitionByNameSet((Set<String>) fflib_match.anyObject())).thenReturn(batchDefinitionList); 
        mocks.when(jobExecutionDO.createJobExecutionsFromBD((ID) fflib_match.anyObject())).thenReturn(jobExecutionList[0]);
        mocks.when(parameterRep.getParametersByBatchDefinitionIdAndName((Set<Id>) fflib_match.anyObject(),(Set<String>) fflib_match.anyObject())).thenReturn(parametersList);
        mocks.when(parameterRep.updateSObjects((List<Parameters__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when( jobExecutionRep.insertSObjects((List<Job_Execution__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();
        TW_OMVEntityEmployee_UpdateUniqueID jobExecutionWorker = new TW_OMVEntityEmployee_UpdateUniqueID();
        jobExecutionWorker = new TW_OMVEntityEmployee_UpdateUniqueID(oMVEntityRepository,batchDefRep,jobExecutionRep,jobExecutionDO,parameterRep);
    
        jobExecutionWorker.execute(oMVEntityEmployeeList,null);
        jobExecutionWorker.execute(null,oMVEntityEmployeeMap);
        jobExecutionWorker.execute(oMVEntityEmployeeList,oMVEntityEmployeeMap);

        ((IREP_OMVEntityEmployee)mocks.verify(oMVEntityRepository, 1)).getCompanyCodeByUserID((Set<ID>)fflib_match.anyObject());
        ((FW_IREP_BatchDefinition)mocks.verify(batchDefRep, 3)).getBatchDefinitionByNameSet((Set<String>)fflib_match.anyObject());
        ((FW_IDO_JobExecution)mocks.verify(jobExecutionDO, 3)).createJobExecutionsFromBD((ID)fflib_match.anyObject());
        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 3)).insertSObjects((List<Job_Execution__c>) fflib_match.eq(jobExecutionList));
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 3)).updateSObjects((List<Parameters__c>) fflib_match.eq(parametersList));
        System.assertEquals(oMVEntityEmployeeList[1], oMVEntityEmployeeList[1]);

    }
    
    @isTest
    private static void updateUniqueIDTestNOkTest(){
        IREP_OMVEntityEmployee oMVEntityRepository = (REP_OMVEntityEmployee)mocks.mock(REP_OMVEntityEmployee.class);
        FW_IREP_BatchDefinition batchDefRep = (FW_REP_BatchDefinition)mocks.mock(FW_REP_BatchDefinition.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IDO_JobExecution jobExecutionDO = (FW_DO_JobExecution)mocks.mock(FW_DO_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>();
        List<CompanyCode__c> companyCodeList = new  List<CompanyCode__c>();
        Map<ID,OMVEntityEmployee__c> oMVEntityEmployeeMap = new Map<ID,OMVEntityEmployee__c>();

        companyCodeList.add(new CompanyCode__c(
            Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
            Name = 'teste',
            Language__c = 'EN'
        ));
        List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>{
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=null,
                OMVEntity__c=companyCodeList[0].Id
            ),
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=fflib_IDGenerator.generate(User.sObjectType),
                OMVEntity__c=companyCodeList[0].Id
            ),
            new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=fflib_IDGenerator.generate(User.sObjectType),
                OMVEntity__c=companyCodeList[0].Id
            )
        };
        oMVEntityEmployeeMap.put(oMVEntityEmployeeList[1].Id,
             new OMVEntityEmployee__c(
                Id = oMVEntityEmployeeList[1].Id,
                EmployeeUser__c = oMVEntityEmployeeList[1].EmployeeUser__c
            )
        );
        oMVEntityEmployeeMap.put(oMVEntityEmployeeList[2].Id,
             new OMVEntityEmployee__c(
                Id = oMVEntityEmployeeList[2].Id,
                EmployeeUser__c = oMVEntityEmployeeList[2].EmployeeUser__c
            )
        );
        mocks.startStubbing();
        mocks.when(oMVEntityRepository.getCompanyCodeByUserID((Set<Id>) fflib_match.anyObject())).thenReturn(oMVEntityEmployeeList);
        mocks.when(batchDefRep.getBatchDefinitionByNameSet((Set<String>) fflib_match.anyObject())).thenReturn(batchDefinitionList); 
        mocks.stopStubbing();

        TW_OMVEntityEmployee_UpdateUniqueID jobExecutionWorker = new TW_OMVEntityEmployee_UpdateUniqueID();
        jobExecutionWorker = new TW_OMVEntityEmployee_UpdateUniqueID(oMVEntityRepository,batchDefRep, jobExecutionRep, jobExecutionDO,parameterRep);
        jobExecutionWorker.execute(oMVEntityEmployeeList,oMVEntityEmployeeMap);
        
    }
}