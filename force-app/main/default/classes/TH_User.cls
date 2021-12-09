/**
* @description   User trigger handler
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* João Lopes                      01/07/2021          Created Class
* ------------------------------------------------------------------------------------ 
*/
public class TH_User extends FW_TriggerHandler{
    private List<User> newList;

    public TH_User(){
        this.newList = (List<User>) Trigger.New;
    }

    protected override void executeBeforeInsert(){
        new TW_User_DisableChatterEmails().execute(newList);
    }
}