/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TH_Event
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
public class TH_EventTest {
    @isTest
    static void eventTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            test.startTest();
            List<Event> eventList = FW_TestDataFactory.createEvent(1, true);
            eventList[0].Subject = 'test update';
            update(eventList);
            test.stopTest();
            System.assertEquals('test update', eventList[0].Subject);
        }
    }
}