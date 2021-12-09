({
	fetchErrors : function(component, event, helper) {	 
        component.set('v.columns', [
            {type: 'button', typeAttributes: {iconName: 'action:preview', label: $A.get("$Label.c.Job_Execution_View_Record_Button"), name: 'showRecord'}},
            {label: 'Error Message', fieldName: 'Error_Message__c', type: 'text'},
            {label: 'Exception Type', fieldName: 'Exception_Type_Name__c', type: 'text'},
        ]);
        
        var action = component.get("c.getErrorList");
        action.setParams({
            jobExecutionId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){	
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.errorList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    createJobs : function(component,event,helper){
        var listErrorsId = [];
        var selectedErrors = component.find("jobsTable").getSelectedRows();
        for(var i = 0; i < selectedErrors.length; i++){
            listErrorsId.push(selectedErrors[i].Id);
        }
        if(listErrorsId.length > 0){
            console.log('>' + listErrorsId.length);
            var action = component.get("c.createJobExecutions");
            action.setParams({
                errorListId : listErrorsId
            });
            action.setCallback(this, function(response){	
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success",
                        "type" : "success",
                        "message": "Job Executions have been created sucessfully"
                    });
                    toastEvent.fire();
                 	var a = component.get('c.init');
        			$A.enqueueAction(a);
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
        }
    }
})