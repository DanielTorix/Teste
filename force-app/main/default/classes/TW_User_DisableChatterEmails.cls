/**
@description    worker class to automatically disable chatter notifications to generate email messages to the users
@testClass      
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* João Lopes                      01/07/2021          Created class
* Hugo Rodrigues                  02/11/2021          updated to meet US41124 requirements
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_User_DisableChatterEmails {

    public TW_User_DisableChatterEmails() {}
    
    public void execute(List<User> newUserList){
        for (User userRecord : newUserList) {
            if(userRecord.UserPreferencesDisableAllFeedsEmail == true){
                userRecord.UserPreferencesDisableAllFeedsEmail = false;     
            }
            if(userRecord.EmailPreferencesAutoBcc == true){
                userRecord.EmailPreferencesAutoBcc = false;     
            }
            
        }
    }

}