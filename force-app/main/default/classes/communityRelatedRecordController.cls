public with sharing class communityRelatedRecordController {
    @AuraEnabled(cacheable=true)
    public static sObject getRelatedRecord(
        String baseObject,
        String recordFilter,
        String relatedRecord,
        List<String> fieldList
    ) {
        String query = 'SELECT ';
        List<String> selectFieldList = new List<String>();

        for (String field : fieldList) {
            selectFieldList.add(relatedRecord + '.' + field);
        }

        query += String.join(selectFieldList, ',');

        query += ' FROM ' + baseObject + ' WHERE ';
        query += parseRecordFilter(recordFilter);

        return Database.query(query);
    }

    public static String parseRecordFilter(String filter) {
        String result;

        result = filter.replace(':UserInfo.getUserId()', '\'' + UserInfo.getUserId() + '\'');

        return result;
    }
}