@isTest
public class FW_ExceptionWrapperTest {

    public class applicationException extends Exception {}

    @isTest
    static void exception_Test(){
        Test.startTest();
            FW_ExceptionWrapper errorWrapper = FW_ExceptionWrapper.exceptionWrapperFactory(new applicationException('add exception'));
        Test.stopTest();
        System.assertEquals('add exception', errorWrapper.message);
    }
    
    @isTest
    static void dmlException_Test(){

        Test.startTest();
            FW_ExceptionWrapper errorWrapper;
            try {                
                Account acc = new Account();
                update acc;
            } catch(DmlException ex) {
                errorWrapper = FW_ExceptionWrapper.exceptionWrapperFactory(ex);
            }
            
        Test.stopTest();

        System.assertEquals('System.DmlException', errorWrapper.typeName);
        System.assertEquals('for index - 0 and record id - null with the error message Id not specified in an update call', errorWrapper.message);
    }
}