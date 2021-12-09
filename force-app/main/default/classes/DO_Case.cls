/**
* @description   Case domain object class
* @testClass     DO_CaseTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                26/05/2021          Created Case Repository
*   Hugo Rodrigues                15/09/2021          added new values
* ------------------------------------------------------------------------------------ 
*/
public class DO_Case implements IDO_Case{
    public final static String CASE_STATUS_CLOSED = 'Closed';
    public final static String CASE_STATUS_COMPLETED = 'Completed';
    public final static String CASE_RECORDTYPE_CASE = 'Case';
    public final static String CASE_RECORDTYPE_CLAIM = 'Claim';
    public final static String CASE_RECORDTYPE_COMPLAINT = 'Complaint';
    public final static String CASE_ORIGIN_EMAIL = 'Email';
    public final static String CASE_SOURCE_CUSTOMER_REPRESENTATIVE = 'Customer - Representative';
    public final static String CASE_SOURCE_INTERNAL = 'Internal';
    public final static String CASE_CATEGORY1_SPAM = 'Spam';
    public final static String CASE_STATUS_RESOLUTIONCUSTOMER = 'Resolution to Customer';
    public final static String CASE_STATUS_CUSTOMERFEEDBACK = 'Customer Feedback';
    public final static String CASE_STATUS_INFORMATIONRECEIVED = 'Information Received';
    public final static String CASE_STATUS_NEW = 'New';
    public final static String CASE_CLOSURE_REASON_COMPLETED_NORMALLY = 'Case Completed';
    public final static String CASE_CLOSURE_REASON_COMPLETED_PARENT = 'All Related Cases Completed';
    public final static String CASE_SOURCE_OTHER = 'Other';
    public final static String CASE_APPROVAL_STARTED = 'Started';
    public final static String CASE_APPROVAL_REJECTED = 'Rejected';
    public final static String CASE_APPROVAL_APPROVED = 'Approved';
    public final static String CASE_ORIGIN_MANUAL = 'Manual';
    public final static Id CASE_RECORDTYPEID_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_CASE).getRecordTypeId();
    public final static Id CASE_RECORDTYPEID_CLAIM = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_CLAIM).getRecordTypeId();
    public final static Id CASE_RECORDTYPEID_COMPLAINT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_COMPLAINT).getRecordTypeId();
    public final static List<Id> CASE_CARDS_RECORDTYPESIDS = new List<Id>{CASE_RECORDTYPEID_CASE, CASE_RECORDTYPEID_CLAIM, CASE_RECORDTYPEID_COMPLAINT};
}