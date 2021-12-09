/**
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */
public with sharing class ExceptionHandler{

    public static List<FPS_Bor_Error_Log__c> errorLogList = new List<FPS_Bor_Error_Log__c>();

   /* public static void createErrorLog(Exception e, String errorClass, String errorContext){
        Error_Log__c errorLog = new Error_Log__c();
        System.debug('Exception: ' + e + ', Message: ' + e.getMessage()+', Line Number: ' + e.getLineNumber()+'\n' + e.getStackTraceString());
        System.debug(errorClass + '====> errorClass');
        System.debug(errorContext + '====> errorContext');
        String errMessage = 'Exception: ' + e + '\n' + ' Message: ' + e.getMessage()+'\n' + ' Line Number: ' + e.getLineNumber()+'\n' + ' Stack Trace: ' + e.getStackTraceString();
        errorLog.Error_Context__c = errorContext;
        errorLog.Error_Class__c = errorClass;
        errorLog.Error_Message__c = errMessage;
        errorLog.Error_Line_Number__c = e.getLineNumber();
        errorLog.Error_Type__c = e.getTypeName();
        System.debug(errorLog + '====> errorLog');
        insert errorLog;
    }*/

    public static void createErrorLogList(String e, String serializedRecord, String errorClass, String errorContext,Id
    recordId, String insertOrUpdate){
        FPS_Bor_Error_Log__c errorLog = new FPS_Bor_Error_Log__c();
        System.debug('Exception: ' + e);
        System.debug('errorClass =====> ' + errorClass);
        System.debug('errorContext =====> ' + errorContext);
        System.debug('recordId =====> ' + recordId);
        System.debug('insertOrUpdate =====> ' + insertOrUpdate);
        String errMessage = 'Exception: ' + e;
        errorLog.Record_Details__c = serializedRecord;
        errorLog.Error_Context__c = errorContext;
        errorLog.Error_Class__c = errorClass;
        errorLog.Error_Message__c = errMessage;
        errorLog.Record_Id__c = recordId;
        errorLog.Insert_Or_Update__c = insertOrUpdate;
        System.debug(errorLog + '====> errorLog');
        errorLogList.add(errorLog);
    }
}