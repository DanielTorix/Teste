/**
    * @description   Interface for ErrorHandling
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public interface FW_ISL_ErrorHandling {
    void writeLog(BatchApexErrorEvent event, Id jobId);
    void writeLog(System_Notification__e event);
    void saveLogs();
}