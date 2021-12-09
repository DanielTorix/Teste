/**
    * @description   Error and Monitoring Log Builder Class
    * @testClass     FW_ErrorAndMonitoringLogTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_ErrorAndMonitoringLog {
	private string notificationType;
    private string category;
    private string origin;
    private string requestBody;
    private string responseBody;
    private string actorId;
    private string recordId;
    private FW_ExceptionWrapper exceptionWrapper;
    private string errorMessage; 
    
    public FW_ErrorAndMonitoringLog() {}
    
    private FW_ErrorAndMonitoringLog(string notificationType, string category,
                                               string origin, string requestBody, 
                                               string responseBody, string actorId,
                                               FW_ExceptionWrapper exceptionWrapper, string errorMessage,
                                               string recordId) {
        this.notificationType = notificationType;
        this.category = category;
        this.origin = origin;
        this.requestBody = requestBody;
        this.responseBody = responseBody;
        this.actorId = actorId;
        this.exceptionWrapper = exceptionWrapper;
        this.errorMessage = errorMessage;
        this.recordId = recordId;
    }
    
    public string getNotificationType() {
		return this.notificationType;
	}
    public string getCategory() {
		return this.category;
	}
    public string getOrigin() {
		return this.origin;
	}
    public string getRequestBody() {
		return this.requestBody;
	}

    public string getResponseBody() {
		return this.responseBody;
	}

    public string getActorId() {
		return this.actorId;
	}
    
    public FW_ExceptionWrapper getExceptionWrapper() {
		return this.exceptionWrapper;
	}
     
    public string getErrorMessage() {
		return this.errorMessage;
	}
    
     public string getRecordId() {
		return this.recordId;
	}

    public class ErrorDetailsBuilder {

        private string notificationType;
        private string category;
        private string origin;
        private string requestBody;
        private string responseBody;
        private string actorId;
		private FW_ExceptionWrapper exceptionWrapper;
        private string errorMessage;
        private string recordId;
        
		public ErrorDetailsBuilder () {
		}

		public ErrorDetailsBuilder setNotificationType(notificationType value) {
			this.notificationType = string.valueOf(value);
			return this;
		}

		public ErrorDetailsBuilder setCategory(categoryType category) {
			this.category = string.valueOf(category);
			return this;
		}

		public ErrorDetailsBuilder setOrigin(String origin) {
			this.origin = origin;
			return this;
		}
        
        public ErrorDetailsBuilder setRequestBody(String requestBody) {
			this.requestBody = requestBody;
			return this;
		}
        
        public ErrorDetailsBuilder setResponseBody(String responseBody) {
			this.responseBody = responseBody;
			return this;
		}
        
        public ErrorDetailsBuilder setActorId(string actorId) {
            this.actorId = actorId;
			return this;
		}
        
        public ErrorDetailsBuilder setExceptionWrapper(FW_ExceptionWrapper exceptionWrapper) {
            this.exceptionWrapper = exceptionWrapper;
			return this;
		}
        
        public ErrorDetailsBuilder setErrorMessage(string errorMessage) {
		    this.errorMessage = errorMessage;
            return this;
	    }

        public ErrorDetailsBuilder setRecordId(string recordId) {
		    this.recordId = recordId;
            return this;
	    }
        
        //to build the error and monitoring log
		public FW_ErrorAndMonitoringLog build() {
			return new FW_ErrorAndMonitoringLog(this.notificationType, this.category,
                                                          this.origin, this.requestBody, 
                                                          this.responseBody,this.actorId, 
                                                          this.exceptionWrapper, this.errorMessage, this.recordId);
			
		}
	}
    
    public Enum notificationType {
        Technical_Error,
        Functional_Error,
        Log
    }

    //should be in sync with Category__c field values on Error_Log__c object
    public Enum categoryType {
          Apex_Class,
          Apex_Trigger,
          Process_Builder,
          HTTP_Callout,
          HTTP_Inbound,
          Vlocity_Omniscript,
          Platform_Event  
    }
    
}