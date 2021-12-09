/**
@author Hugo Rodrigues  
@date   04/11/2021 
@description Test class for Async_EmployeeEntityUpdate
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues               04/11/2021           Original Version                         100
*/
@isTest
private class Async_EmployeeEntityUpdateTest {
    
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void EmployeeEntityUpdateTest() {
        IREP_OMVEntityEmployee oMVEntityRepository = (REP_OMVEntityEmployee)mocks.mock(REP_OMVEntityEmployee.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        IREP_Lead leadRepository = (REP_Lead)mocks.mock(REP_Lead.class);
        List<User> userList = new List<User> {
            new User(
                Id= fflib_IDGenerator.generate(User.sObjectType)
            )
            
        };
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
         //Create JobExecution
         List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true,
                Status__c = FW_DO_JobExecution.JOB_EXEC_STATUS_NEW
            )
        };
        //Create Parameters 
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'OwnerIDFromLead',
                Value__c = string.valueof(new Set<ID>{userList[0].Id}).replace('{', '').replace('}', '')
            ),
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = 'Status',
             
                Value__c = 'New,Working'
            ),
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = FW_AsyncHandler.DEFAULT_PARAMETER
            )   
        };


       
            List<OMVEntityEmployee__c> oMVEntityEmployeeList = new  List<OMVEntityEmployee__c>{
                new OMVEntityEmployee__c(
                Id = fflib_IDGenerator.generate(OMVEntityEmployee__c.sObjectType),
                EmployeeUser__c=userList[0].Id,
                OMVEntity__c=fflib_IDGenerator.generate(CompanyCode__c.sObjectType)
            ) 
            };
            List<Lead> leadList = new  List<Lead>{
                new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                OwnerId = userList[0].Id
            ) ,
            new Lead(
                Id = fflib_IDGenerator.generate(Lead.sObjectType),
                OwnerId= fflib_IDGenerator.generate(User.sObjectType)
            ) 
            };
            
            mocks.startStubbing();
            mocks.when(oMVEntityRepository.getCompanyCodeByUserID((Set<Id>)fflib_match.anyObject())).thenReturn( oMVEntityEmployeeList );
            mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
            mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
            mocks.when(leadRepository.updateSObjects((List<Lead>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
            mocks.stopStubbing();

            Async_EmployeeEntityUpdate newBatchRun = new Async_EmployeeEntityUpdate();
            newBatchRun = new Async_EmployeeEntityUpdate(oMVEntityRepository,jobExecutionRep,parameterRep,leadRepository);
            
            
            Database.executeBatch(newBatchRun);
            newBatchRun.setAsyncApexJobId(null);
            newBatchRun.execute(null, leadList);
            ((IREP_OMVEntityEmployee)mocks.verify(oMVEntityRepository, 1)).getCompanyCodeByUserID((Set<ID>)fflib_match.anyObject());
            ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
            ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
            ((IREP_Lead)mocks.verify(leadRepository, 1)).updateSObjects((List<Lead>) fflib_match.eq(leadList));
    }
}