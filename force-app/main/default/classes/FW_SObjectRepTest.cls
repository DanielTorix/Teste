@isTest
public class FW_SObjectRepTest {

    @TestSetup
        static void makeData(){
            List<User> userList = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null);
    }

    @isTest
    static void insertSObjects_allOrNone_false_Test(){
       
        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Database.SaveResult> insertilist ;
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            insertilist=sobjectRepObject.insertSObjects(new List<Batch_Definition__c>{ new Batch_Definition__c(Batch_Name__c = 'test1', Class_Name__c = 'test1', SObject_API_Name__c='FW_SObjectRep'), new Batch_Definition__c(Batch_Name__c = 'test2',Class_Name__c = 'test2', SObject_API_Name__c='FW_SObjectRep')});
        }
            
        Test.stopTest();
        System.assertEquals(true, insertilist.size()>0);
    }

    @isTest
    static void insertSObjects_allOrNone_true_Test(){
       
        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];

        Test.startTest();
        List<Database.SaveResult> srList;
        System.runAs(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            srList = sobjectRepObject.insertSObjects(new List<Error_Log__c>{new Error_Log__c(), new Error_Log__c()});
        }
        Test.stopTest();
        System.assertEquals(true, srList.size() > 0);
    }
   
    @isTest
    static void updateSObjects_allOrNone_false_Test(){

        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Database.SaveResult> insertilist ;
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();

            Batch_Definition__c newBD = new Batch_Definition__c(Batch_Name__c = 'test1', Class_Name__c = 'test1', SObject_API_Name__c='FW_SObjectRep');
            insert newBD;
            
            insertilist=sobjectRepObject.updateSObjects(new List<Batch_Definition__c>{newBD});
        }
        Test.stopTest();
        System.assertEquals(true, insertilist.size() > 0);
    }

    @isTest
    static void updateSObjects_allOrNone_true_Test(){

        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Error_Log__c> errorlist = [select id from Error_Log__c limit 1];
        List<Database.SaveResult> srList= new List<Database.SaveResult>();
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            srList = sobjectRepObject.updateSObjects(errorlist);
        }
        Test.stopTest();
        System.assertNotEquals(1, srList.size());
    }
     
    @isTest
    static void upsertSObjects_allOrNone_false_Test(){
        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Database.UpsertResult> insertilist ;
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            insertilist=sobjectRepObject.upsertSObjects(new List<Batch_Definition__c>{ new Batch_Definition__c(Batch_Name__c = 'test1', Class_Name__c = 'test1', SObject_API_Name__c='FW_SObjectRep'), new Batch_Definition__c(Batch_Name__c = 'test2',Class_Name__c = 'test2', SObject_API_Name__c='FW_SObjectRep')});
        }
        Test.stopTest();
        System.assertEquals(true, insertilist.size() > 0);
    }

    @isTest
    static void upsertSObjects_allOrNone_true_Test(){

        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Error_Log__c> errorlist = [select id from Error_Log__c limit 1];
        List<Database.UpsertResult> srList= new List<Database.UpsertResult>();

        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            srList = sobjectRepObject.upsertSObjects(errorlist);
        }
        Test.stopTest();
        System.assertNotEquals(1, srList.size());
    }

    @isTest
    static void upsertSObjectsByExternalId_Test(){
        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Database.UpsertResult> srList= new List<Database.UpsertResult>();
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
             srList = sobjectRepObject.upsertSObjects(FW_TestDataFactory.createBatchDefinition(1,false), Batch_Definition__c.Batch_Name__c);
        
        }
        Test.stopTest();
        System.assertEquals(1, srList.size());
    } 

    @isTest
    static void deleteSObjects_allOrNone_false_Test(){

        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];
        List<Database.DeleteResult> insertilist ;
        List<Error_Log__c> errorList = [select id from Error_Log__c limit 10000];
        Test.startTest();
        System.runas(u){
            FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
            insertilist=sobjectRepObject.deleteSObjects(errorList);

            FW_SObjectRep sobjectRepObject1 = new FW_SObjectRep();
            sobjectRepObject1.deleteSObjects(errorList);

        }
        Test.stopTest();
        System.assertEquals(false, insertilist.size() > 0);
    }

    @isTest
    static void deleteSObjects_allOrNone_true_Test(){
        User u = [select id from User where Profile.name = 'System Administrator' AND IsActive = true LIMIT 1];                                   
        List<Error_Log__c> errorList = [select id from Error_Log__c limit 10000];
        Test.startTest();
        List<Database.DeleteResult> srList;
            System.runAs(u){
                FW_SObjectRep sobjectRepObject = new FW_SObjectRep();
                srList = sobjectRepObject.deleteSObjects(errorList);
            }
        Test.stopTest();
        System.assertEquals(false, srList.size() > 0);
    }

    @isTest
    static void setAllOrNoneTest(){
        FW_SObjectRep nClass = new FW_SObjectRep();
        nClass.setAllOrNone(true);
    }
}