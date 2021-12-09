/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TH_Task
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
public class TH_TaskTest {
    @isTest
    static void taskTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            test.startTest();
            List<Task> taskList = FW_TestDataFactory.createTask(1, true);
            taskList[0].Subject = 'test update';
            update(taskList);
            test.stopTest();
            System.assertEquals('test update', taskList[0].Subject);
        }
    }
}