@isTest
private class FW_REP_CronTriggerTest {

    @isTest
    private static void getCronTriggerListByIdTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        system.runAs(runningUser){    
            FW_TestBatch testBatch =new FW_TestBatch();
            String cronExpression ='0 5 2 * * ?';
            
            test.startTest();
                Id jobId = System.schedule('Test Batch', cronExpression , testBatch);
            test.stopTest();

            FW_REP_CronTrigger cronTriggerRepository = new FW_REP_CronTrigger();
            List<CronTrigger> cronTriggerList = cronTriggerRepository.getCronTriggerListById(new List<Id>{ jobId });
            
            system.assertEquals(1, cronTriggerList.size());
            system.assertEquals('Test Batch', cronTriggerList[0].CronJobDetail.Name );
        }
    }
}