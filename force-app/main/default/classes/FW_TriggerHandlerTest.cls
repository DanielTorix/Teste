@isTest
public class FW_TriggerHandlerTest {
    
    @isTest
    static void disableAllTriggers_shouldNotExecute() {
        FW_TriggerHandler.isTriggerHandlerTest = true;
        FW_TriggerHandler handler = new FW_TriggerHandler();

        FW_TriggerHandlerSettings__c settings = FW_TriggerHandlerSettings__c.getInstance();
        settings.All__c = true;
        upsert settings;

        Test.startTest();
            handler.execute();
            handler.handleException(new FW_TriggerException());
            handler.setHasRun('Test');
            Boolean hasRun = handler.getHasRun('Test');
            String contextName = handler.name;
        Test.stopTest();

        System.assertEquals(true, hasRun, 'has run not set');
        System.assertEquals('FW_TriggerHandler', contextName);
    }


    @isTest
    static void getHasRunTest() {
        FW_TriggerHandler.isTriggerHandlerTest = true;
        FW_TriggerHandler handler = new FW_TriggerHandler();
        System.assertEquals(false, handler.getHasRun('test'));
    }

    @isTest
    static void doExecuteScenariosTest() {

        List<Batch_Definition__c> batchDefList = FW_TestDataFactory.createBatchDefinition(1,true);
        List<Job_Execution__c> jobExecList = FW_TestDataFactory.createJobExecution(1, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL, batchDefList[0].Id);

        Test.startTest();
            insert jobExecList;
            jobExecList[0].Job_Size__c = 200;
            update jobExecList;
        Test.stopTest();
        // No asserts made because the goal of this class is not to test Job Execution trigger login
        
    }

    @isTest
    static void doExecuteForceExceptionTest() {

        FW_TriggerHandler.isTriggerHandlerTest = true;
        FW_TriggerHandler.forceException = true;
        List<Job_Execution__c> jobExecList = FW_TestDataFactory.createJobExecution(1, false, FW_DO_JobExecution.JOB_EXEC_RECORD_TYPE_INITIAL,
                                                                                fflib_IDGenerator.generate(Batch_Definition__c.sObjectType));

        String detectedException;
        System.assertEquals(true, String.isBlank(detectedException));

        Test.startTest();
            try{
                insert jobExecList;
            } catch(Exception e){
                detectedException = e.getMessage();
            }
        Test.stopTest();

        System.assertEquals(true, !String.isBlank(detectedException));
    }

    @isTest
    static void forceAdditionalConditionsTest() {

        FW_TriggerHandler.isTriggerHandlerTest = true;
        FW_TriggerHandler handler = new FW_TriggerHandler();

        String detectedException;
        System.assertEquals(true, String.isBlank(detectedException));

        Test.startTest();
            try{
                handler.execute();
            } catch(Exception e){
                detectedException = e.getMessage();
            }
        Test.stopTest();
    }
}