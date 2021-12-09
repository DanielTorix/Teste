/**
* @description   EncryptedDataGDPR__c domain object class
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                29/09/2021          Created EncryptedDataGDPR__c domain
* ------------------------------------------------------------------------------------ 
*/
public class DO_EncryptedDataGDPR implements IDO_EncryptedDataGDPR{
    public final static CEPEncrypt__c orgDefaults = CEPEncrypt__c.getOrgDefaults();

    /**
    * @description method to encrypt data
    * @author Guilherme Charro | 29-09-2021 
    * @param data data to be encrypted 
    * @return String this string is the encrypted value of the data 
    **/
    public static String encryptData(String data){
        String returned = null;
        if (data != null) {
            returned = EncodingUtil.base64Encode(Crypto.encrypt(orgDefaults.AlgorithmName__c, EncodingUtil.base64Decode(orgDefaults.Key__c), Blob.valueOf(orgDefaults.Vector__c), Blob.valueOf(data)));
        }
        return returned;
    }

    /**
    * @description method to create a new EncryptedDataGDPR__c record
    * @author Guilherme Charro | 29-09-2021 
    * @param mobile encrypted mobile data to be assigned to the record
    * @param business encrypted business phone data to be assigned to the record
    * @param email encrypted email data to be assigned to the record
    * @return EncryptedDataGDPR__c record that was created 
    **/
    public static EncryptedDataGDPR__c createEncryptedData(String mobile, String business, String email){
        EncryptedDataGDPR__c encrypedDataRecord = null;

        if (mobile != null || business != null || email != null) {
            encrypedDataRecord = new EncryptedDataGDPR__c(
                MobilePhoneEncrypted__c = mobile,
                BusinessPhoneEncrypted__c = business,
                EmailEncrypted__c = email
            );
        }

        return encrypedDataRecord;
    }
}