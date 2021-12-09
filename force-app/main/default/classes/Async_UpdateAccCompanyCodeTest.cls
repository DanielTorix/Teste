@isTest
private class Async_UpdateAccCompanyCodeTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void Async_UpdateAccCompanyCodeTest() {
        IREP_AccountCountryRelatedSetting accountCountryRelatedRepository = (REP_AccountCountryRelatedSetting)mocks.mock(REP_AccountCountryRelatedSetting.class);
        FW_IREP_JobExecution jobExecutionRep = (FW_REP_JobExecution)mocks.mock(FW_REP_JobExecution.class);
        FW_IREP_Parameters parameterRep = (FW_REP_Parameters)mocks.mock(FW_REP_Parameters.class);
        
        //Create Batch_Definition
        List<Batch_Definition__c> batchDefinitionList = new List<Batch_Definition__c>{
            new Batch_Definition__c(
                Id = fflib_IDGenerator.generate(Batch_Definition__c.sObjectType),
                Batch_Name__c = 'BatchTest',
                Class_Name__c = 'Async_UpdateAccCompanyCode',
                Job_Size__c = 200,
                SObject_API_Name__c = 'Case'
            )
        };
            
        //Create Parameters
        List<Parameters__c> parametersList = new List<Parameters__c>{
            new Parameters__c(
                Id = fflib_IDGenerator.generate(Parameters__c.sObjectType),
                Name = FW_AsyncHandler.DEFAULT_PARAMETER
            )   
        };

        //Create JobExecution
        List<Job_Execution__c> jobExecutionList = new List<Job_Execution__c>{
            new Job_Execution__c(
                Id = fflib_IDGenerator.generate(Job_Execution__c.sObjectType),
                Batch_Definition__c = batchDefinitionList.get(0).id,
                Run_With_Defaults__c = true              
            )
        };

        List<CompanyCode__c> companyCodeList = new List<CompanyCode__c>{
            new CompanyCode__c(
                Id = fflib_IDGenerator.generate(CompanyCode__c.sObjectType),
                Country__c = 'RO',
                Language__c = 'EN'
            )
        };

        //insert companyCodeList;

        List<Account> accountList = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                Name = 'teste',
                CompanyCode__c = companyCodeList[0].Id,
                CompanyCode__r = companyCodeList
            )
        };

        //insert accountList;

        List<Case> caseList = new List<Case>{
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Subject = 'teste',
                AccountId = accountList[0].Id,
                Account = accountList[0],
                CompanyCodeCountry__c = 'teste'
            )
        };


        List<AccountCountryRelatedSetting__mdt> metadataList = new List<AccountCountryRelatedSetting__mdt>{
            new AccountCountryRelatedSetting__mdt(
                MasterLabel = 'Case',
                AccountLookupAPIName__c = 'AccountId',
                CountryAPIName__c = 'CompanyCodeCountry__c',
                AccountRelationshipName__c = 'Account',
                Objectfilter__c = 'Subject LIKE \'teste\''
            ),
            new AccountCountryRelatedSetting__mdt(
                MasterLabel = 'Opportunity',
                AccountLookupAPIName__c = 'AccountId',
                CountryAPIName__c = 'CompanyCodeCountry__c',
                AccountRelationshipName__c = 'Account'
            )
        };
            
        List<SObject> sobjectList = new List<SObject>{
            caseList[0]
        };

        mocks.startStubbing();
        mocks.when(accountCountryRelatedRepository.getAllAccountCountryRelated()).thenReturn(metadataList);
        mocks.when(jobExecutionRep.getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(jobExecutionRep.getJobExecutionByAsyncApexJobIdSet((Id)fflib_match.anyObject())).thenReturn(jobExecutionList);
        mocks.when(parameterRep.getParametersByParentId((Set<Id>)fflib_match.anyObject())).thenReturn(parametersList);
        mocks.stopStubbing();

        Map<String, AccountCountryRelatedSetting__mdt> relatedObjectsToUpdateMap = new Map<String, AccountCountryRelatedSetting__mdt>();
        for(AccountCountryRelatedSetting__mdt metadataRecord : accountCountryRelatedRepository.getAllAccountCountryRelated()) {
            relatedObjectsToUpdateMap.put(metadataRecord.MasterLabel, metadataRecord);
        }
        
        Async_UpdateAccCompanyCode newBatchRun = new Async_UpdateAccCompanyCode();
        newBatchRun = new Async_UpdateAccCompanyCode(accountCountryRelatedRepository, jobExecutionRep, parameterRep);
        newBatchRun.accountIdsSet = new Set<Id>{accountList[0].Id};
 
        
        Database.executeBatch(newBatchRun);
        newBatchRun.setAsyncApexJobId(null);
        newBatchRun.keyList = new List<String>{'Case', 'Account', 'Opportunity'};
        newBatchRun.relatedObjectsToUpdateMap = relatedObjectsToUpdateMap;
        newBatchRun.execute(null, sobjectList);

        ((FW_IREP_JobExecution)mocks.verify(jobExecutionRep, 1)).getJobExecWithBatchDefinitionsByIdSet((Set<Id>)fflib_match.anyObject());
        ((FW_IREP_Parameters)mocks.verify(parameterRep, 1)).getParametersByParentId((Set<Id>)fflib_match.anyObject());
        ((IREP_AccountCountryRelatedSetting)mocks.verify(accountCountryRelatedRepository, 1)).getAllAccountCountryRelated();
    }
}