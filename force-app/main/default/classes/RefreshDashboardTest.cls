/**
 * Created by mateuszbednarek on 22/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
*/

@isTest
public with sharing class RefreshDashboardTest {

    @IsTest
    public static void testUpdateWorkdaysBatch(){

        Test.setMock(HttpCalloutMock.class, new RefreshDashboardMock());
        Test.startTest();
            RefreshDashboards.refresh();
        Test.stopTest();
    }
}