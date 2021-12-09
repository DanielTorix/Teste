/**
* @description   Test class for the class SL_PermissionSetVerification
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Alencar                    15/09/2021          Created Class
* ------------------------------------------------------------------------------------ 
* João Alencar                    15/09/2021           94%
*/

@isTest
public with sharing class SL_PermissionSetVerificationTest {

    @isTest
    static void PermissionSetVerificationTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);

        PermissionSetGroup permissionGroup = FW_TestDataFactory.createPermissionSetGroupWithComponent();
        FW_TestDataFactory.createAndAssignPermissionSetToUser(runningUser.Id);
        System.runAs(runningUser){
            
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetGroupId = permissionGroup.Id, AssigneeId = runningUser.Id
            );
            insert assignment;
            SL_PermissionSetVerification.wrapperVerificationInputs wrapper = new SL_PermissionSetVerification.wrapperVerificationInputs();
            wrapper.currentUserId = runningUser.Id;
            wrapper.PermissionSetsLabels = new list<String>{'testFactory'};

            Test.startTest();
                List<List<String>> result = SL_PermissionSetVerification.VerifyPermissionSet( new List<SL_PermissionSetVerification.wrapperVerificationInputs>{wrapper} );
  
                wrapper.PermissionSetsLabels = new list<String>{'testFactoryGroup'};
                List<List<String>> secondResult = SL_PermissionSetVerification.VerifyPermissionSet( new List<SL_PermissionSetVerification.wrapperVerificationInputs>{wrapper} );

                wrapper.PermissionSetsLabels = new list<String>{'nonExisting'};
                List<List<String>> thirdResult = SL_PermissionSetVerification.VerifyPermissionSet( new List<SL_PermissionSetVerification.wrapperVerificationInputs>{wrapper} );
            Test.stopTest();

            system.assertNotEquals(null, result);

            system.assertEquals(null, secondResult);
            system.assertEquals(null, thirdResult);

        }
    }
}