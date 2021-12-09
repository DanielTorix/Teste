@isTest
public class FW_ErrorAndMonitoringLogTest {

    public class applicationException extends Exception {}

    @isTest
    static void buildTest(){
        new FW_ErrorAndMonitoringLog();
        Test.startTest();
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setNotificationType(FW_ErrorAndMonitoringLog.notificationType.Technical_Error)
                            .setCategory(FW_ErrorAndMonitoringLog.categoryType.Apex_Class)
                            .setOrigin('unitTest')
                            .setRequestBody('RequestBody')
                            .setResponseBody('ResponseBody')
                            .setActorId(UserInfo.getUserId())
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .setRecordId('001exampleId')
                            .build();  

        Test.stopTest();
        System.assertEquals(string.valueOf(FW_ErrorAndMonitoringLog.categoryType.Apex_Class), error.getCategory());
        System.assertEquals(string.valueOf(FW_ErrorAndMonitoringLog.notificationType.Technical_Error), error.getNotificationType());
        System.assertEquals('unitTest', error.getOrigin());
        System.assertEquals('RequestBody', error.getRequestBody());
        System.assertEquals('ResponseBody', error.getResponseBody());
        System.assertEquals(UserInfo.getUserId(), error.getActorId());
        System.assertEquals('add exception', error.getExceptionWrapper().message);
        System.assertEquals('add exception', error.getErrorMessage());
        System.assertEquals('001exampleId', error.getRecordId());
    }
}