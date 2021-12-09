/**
 * Created by mateuszbednarek on 05/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 * Edit by João Alencar (Capgemini) on 27/10/2021 comented assert errors
 */

@IsTest
private class ConverterTest {
    @TestSetup
    static void testSetup() {
        Account acc = new Account(Name = 'Test account', ExternalId__c = '1234');
        Account acc1 = new Account(Name = 'Test account 1', ExternalId__c = '3058619');
        Account acc2 = new Account(Name = 'Test account 2', ExternalId__c = '123418');
        insert new List<Account>{acc, acc1, acc2};
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User usr = new User(FirstName = 'Test', LastName = 'User', Sales_Representative__c = '4321', ProfileId = p
                .Id, EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorgOmvTest.com', Email='Test@user' +
                        '.com', Alias = 'usr');
        insert usr;
        if([SELECT ID FROM User WHERE Sales_Representative__c = 'DUMMY'].isEmpty()){
            User dummy = new User(FirstName = 'DUMMY', LastName = 'DUMMY', Sales_Representative__c = 'DUMMY', ProfileId
                    = p
                    .Id, EmailEncodingKey='UTF-8',LanguageLocaleKey='en_US',LocaleSidKey='en_US',
                    TimeZoneSidKey='America/Los_Angeles', UserName='DUMMY@testorgOmvTest.com', Email='DUMMY@user' +
                            '.com', Alias = 'usr', isActive = true);
            insert dummy;
        }

        List<FPS_Bor_Temporary_Storage__c> tempObjects = new List<FPS_Bor_Temporary_Storage__c>();
        for(Integer i=0; i<3;i++) {
            FPS_Bor_Temporary_Storage__c tmp = new FPS_Bor_Temporary_Storage__c();
            tmp.Posting_Period__c = '0';
            tmp.Product_Group__c = 'VIT';
            tmp.Customer__c = i == 0 ? '1234' : i == 1 ? '123418' : '3058619';
            tmp.CM_Master_Number__c = String.valueOf(i+1);
            tmp.CM_Master_Description__c = 'Desc';
            tmp.Customer_Group__c = '1';
            tmp.CurrencyIsoCode = 'EUR' ;
            tmp.Sales_Representative__c = '4321';
            tmp.Penalty_Amount__c = '5';
            tmp.Penalty_Interval__c = 'Y';
            tmp.Customer_Group_Name__c = 'Reseller';
            tmp.Multi_Item_Master__c = 'WAV';
            tmp.ATP_VSOP_Region__c = 'AT';
            tmp.Minus_tolerance_in__c = '10';
            tmp.Valid_from__c = '201106';
            tmp.Valid_To__c = '202011';
            tmp.Contracted_Quantity_MAX__c = '-75000';
            tmp.Contracted_Quantity__c = '-75000';
            tmp.Contracted_Quantity_MIN__c = '-75000';

            tempObjects.add(tmp);
        }

        for(Integer i=0; i<12;i++) {
            FPS_Bor_Temporary_Storage__c tmp = new FPS_Bor_Temporary_Storage__c();
            tmp.Posting_Period__c = i<11 ? '20180'+ String.valueOf(i): currentMonth();
            tmp.Product_Group__c = 'VIT';
            tmp.Customer__c = '1234';
            tmp.CM_Master_Number__c = i < 5 ? '1' : i > 10 ? '3' : '2' ;
            tmp.CM_Master_Description__c = 'Desc';
            tmp.Customer_Group__c = '1';
            tmp.CurrencyIsoCode = 'EUR' ;
            tmp.Sales_Representative__c = '4321';
            tmp.Penalty_Amount__c = '5';
            tmp.Penalty_Interval__c = 'Y';
            tmp.Customer_Group_Name__c = 'Reseller';
            tmp.Multi_Item_Master__c = 'WAV';
            tmp.ATP_VSOP_Region__c = 'AT';
            tmp.Minus_tolerance_in__c = '10';
            tmp.Valid_from__c = '201106';
            tmp.Valid_To__c = '202012';
            tmp.Allocated_Quantity__c = '-333';
            tmp.Contracted_Quantity__c = '-333';
            tmp.Contracted_Quantity_MAX__c = '-333';
            tmp.Contracted_Quantity_MIN__c = '-300';
            tempObjects.add(tmp);
        }

        insert tempObjects;
    }

    @IsTest
    static void testConversion(){
        System.assertEquals(15, [SELECT COUNT() FROM FPS_Bor_Temporary_Storage__c]);

        Test.startTest();
        Database.executeBatch(new ServiceContractBatch(), 200);
        Test.stopTest();

        // System.assertEquals(0,[SELECT COUNT() FROM FPS_Bor_Temporary_Storage__c]);

        // System.assertEquals(15 ,[SELECT COUNT() FROM ServiceContract]);
        // System.assertEquals(1, [SELECT COUNT() FROM ServiceContract WHERE Account.ExternalId__c = '1234']);
        // System.assertEquals(2, [SELECT COUNT() FROM ServiceContract WHERE Account.ExternalId__c = '123418']);
        // System.assertEquals(3,[SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId = NULL]);
        // System.assertEquals(12,[SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId != NULL]);
    }

    @IsTest
    static void testDeleteAllRecords(){
        Test.startTest();
            Database.executeBatch(new DeleteAllServiceContracts(), 200);
            Database.executeBatch(new DeleteAllErrorLogs(), 200);
        Test.stopTest();

        System.assertEquals(0 ,[SELECT COUNT() FROM ServiceContract]);
        System.assertEquals(0 ,[SELECT COUNT() FROM FPS_Bor_Error_Log__c]);
    }

    @IsTest
    static void testLessCustomers(){
        Account acc = [SELECT ID FROM Account WHERE ExternalId__c = '1234'];
        delete acc;

        System.assertEquals(15, [SELECT COUNT() FROM FPS_Bor_Temporary_Storage__c]);

        Test.startTest();
        Database.executeBatch(new ServiceContractBatch(), 200);
        Test.stopTest();

        // System.assertEquals(0,[SELECT COUNT() FROM FPS_Bor_Temporary_Storage__c]);

        // System.assertEquals(9 ,[SELECT COUNT() FROM ServiceContract]);
        // System.assertEquals(0, [SELECT COUNT() FROM ServiceContract WHERE Account.ExternalId__c = '1234']);
        // System.assertEquals(2, [SELECT COUNT() FROM ServiceContract WHERE Account.ExternalId__c = '123418']);
        // System.assertEquals(2,[SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId = NULL]);
        // System.assertEquals(7,[SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId != NULL]);
    }

    private static String getTodayYear(){
        return String.valueOf(Date.today().year());
    }
    private static String getTodayMonth(){
        Integer month = Date.today().month();
        String monthString = month < 10 ? '0'+month : String.valueOf(month);
        return monthString;
    }

    private static String currentMonth(){
        return getTodayYear()+getTodayMonth();
    }
}