/**
 * Created by mateuszbednarek on 20/01/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 * Edit by João Alencar (Capgemini) on 27/10/2021 fixed country codes
 */

public with sharing class Util {

    public static Map<String, String> countryNameToCode = new Map<String,String>{
            'Austria' => 'AT',
            'Germany' => 'DE',
            'Slovenia' => 'SL',
            'Hungary' => 'HU',
            'Slovakia' => 'SK',
            'Czechia' => 'CZ',
            'Romania' => 'RO',
            'Bulgaria' => 'BG',
            'Serbia' => 'SH',
            'Moldova' => 'MD'
    };

    static Set<Schema.FieldSetMember>  fieldToConvertToNumber = new Set<Schema.FieldSetMember>(readFieldSet
            ('Number_type_fields',
                    'FPS_Bor_Temporary_Storage__c'));

    public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        return fieldSetObj.getFields();
    }

    /*public static String queryRecordBasedOnFieldSet(String fieldSetName, String objectName, String additionalFields,
            String whereClause){
        String query = 'SELECT ';
        for(Schema.FieldSetMember f : readFieldSet(fieldSetName, objectName)) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id' ;
        system.debug('additionalFields '+additionalFields);
        if(additionalFields != ''){
            query += ','+ additionalFields;
        }
        query += ' FROM '+objectName;
        if(whereClause != ''){
            query += ' WHERE '+whereClause;
        }
        return query;
    }*/

    public static void upsertRecords(List<sObject> toUpsert, Schema.sObjectField upsertField, Type caller, String
            method){
        Integer i = 0;
        List<Database.UpsertResult> saveResults = Database.upsert(toUpsert, upsertField, false);
        for (Database.UpsertResult result : saveResults){
            if (!result.isSuccess()){
                handleError(result, toUpsert.get(i), result.getId(),result.isCreated(), caller, method);
            }
            i++;
        }
        system.debug('Error list ===> '+ExceptionHandler.errorLogList);

        if(!ExceptionHandler.errorLogList.isEmpty()){
            insert ExceptionHandler.errorLogList;
            ExceptionHandler.errorLogList.clear();
        }
    }
    private static void handleError(Database.UpsertResult result, sObject recordFailedToLoad, Id recordId, Boolean
            isInsert, Type caller, String
            method){
        String context = isInsert? 'Insert' : 'Update';
        String errorMessage = '';
        for (Database.Error err : result.getErrors()){
            errorMessage += err.getMessage();
        }
        ExceptionHandler.createErrorLogList(errorMessage, JSON.serialize(recordFailedToLoad), caller.getName(), method,
                recordId,
                context);
    }
}