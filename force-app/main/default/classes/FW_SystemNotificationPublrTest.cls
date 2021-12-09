@istest
public class FW_SystemNotificationPublrTest {

    public class applicationException extends Exception {}

    @testSetup static void setData() {
        FW_TestDataFactory.createDisableErrorLogging();
        List<User> userList = FW_TestDataFactory.createUsers(1, false, 'System Administrator', null);
        userList[0].firstName='testUser';
        insert userlist;
    }

    @istest
    static void publisherTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        FW_SystemNotificationPublr notification = new FW_SystemNotificationPublr();
        Test.startTest();
        system.runas(u){
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .build();
            notification = new FW_SystemNotificationPublr(error);
            System.assertEquals(false,notification.notifyList.isempty(), 'There is');
        }        
        Test.stopTest();  
    }

    @istest
    static void publisherDisableTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        Test.startTest();
        system.runas(u){
            FW_SystemNotificationPublr.isPublisherTest = true;
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            //.setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .build();
            new FW_SystemNotificationPublr(error);
        }
        Test.stopTest();
        System.assertEquals(1, [select id from Error_Log__c].size()); //assert 1
    }

    @istest
    static void publisherListTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        FW_SystemNotificationPublr notification ;
        Test.startTest();
        system.runas(u){
            List<FW_ErrorAndMonitoringLog> errorLogList= new List<FW_ErrorAndMonitoringLog>();
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .build();

            errorLogList.add(error);
            notification=new FW_SystemNotificationPublr(errorLogList);
            System.assertEquals(false,notification.notifyList.isempty(), 'There is');
        }       
        Test.stopTest();
    }

    @istest
    static void publisherListForcingIsDisabledTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        FW_SystemNotificationPublr.isPublisherTest = true;
        FW_SystemNotificationPublr notification ;
        Test.startTest();
        system.runas(u){
            List<FW_ErrorAndMonitoringLog> errorLogList= new List<FW_ErrorAndMonitoringLog>();
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .build();

            errorLogList.add(error);
            notification=new FW_SystemNotificationPublr(errorLogList);
            System.assertEquals(true,notification.notifyList.isempty(), 'There is');
        }       
        Test.stopTest();
    }


    @istest
    static void publisherListDisabledTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        FW_SystemNotificationPublr notification ;
        Test.startTest();
        system.runas(u){
            FW_SystemNotificationPublr.isPublisherTest = true;
            List<FW_ErrorAndMonitoringLog> errorLogList= new List<FW_ErrorAndMonitoringLog>();
            FW_ErrorAndMonitoringLog error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            //.setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception')))
                            .setErrorMessage('add exception')
                            .build();

            errorLogList.add(error);
            notification=new FW_SystemNotificationPublr(errorLogList);
            System.assertEquals(false,notification.notifyList.isempty(), 'There is');
        }       
        Test.stopTest();
    }
    
    @istest
    static void publisherDMLExceptionTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        Test.startTest();
        system.runas(u){
            FW_SystemNotificationPublr.isPublisherTest = true;
            FW_ErrorAndMonitoringLog error;
            try{                
                Account acc = new Account();
                update acc;
            } catch(DmlException ex){
                error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(ex))
                            .setErrorMessage('DmlException')
                            .build();
            }
            new FW_SystemNotificationPublr(error);
        }
        Test.stopTest();
        System.assertEquals(0, [select id from Error_Log__c].size());
    }

    @istest
    static void publisherQueryExceptionTest(){
        User u = [select id from User where Profile.name = 'System Administrator' and firstname='testUser'];
        Test.startTest();
        System.runas(u){
            FW_SystemNotificationPublr.isPublisherTest = true;
            FW_ErrorAndMonitoringLog error;
            try {                
                String query = new FW_QueryBuilder(Job_Execution__c.SObjectType)
                    .selectFields(new SObjectField[]{Job_Execution__c.ID})
                    .whereIn('Id1', new List<Id>())
                    .getQuery();

                Database.query(query);
            } catch(QueryException ex) {
                error = new FW_ErrorAndMonitoringLog.ErrorDetailsBuilder()
                            .setOrigin('unitTest')
                            .setExceptionWrapper(FW_ExceptionWrapper.exceptionWrapperFactory(ex))
                            .setErrorMessage('add exception')
                            .build();
            }

            new FW_SystemNotificationPublr(error);
        }
        Test.stopTest();
        System.assertEquals(0, [select id from Error_Log__c].size());
    }
}