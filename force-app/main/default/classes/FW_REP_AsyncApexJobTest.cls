@isTest
public class FW_REP_AsyncApexJobTest {
    static testMethod void asyncApexJobRepositoryTest(){
        Id jobId = Database.executeBatch(new FW_TestBatch(), 200);
        
        test.startTest();
            FW_REP_AsyncApexJob asyncApexJobRepository = new FW_REP_AsyncApexJob();
            List<AsyncApexJob> asyncApexJobList = asyncApexJobRepository.getAsyncApexJobListByIdSet(new Set<Id>{jobId});
        test.stopTest();
        
        system.assertEquals(1, asyncApexJobList.size());
    }
}