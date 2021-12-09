/**
    * @description   Wrapper Class for Exceptions
    * @testClass     FW_ExceptionWrapperTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public virtual class FW_ExceptionWrapper {
    public Exception cause {get; set;}
    public Integer lineNumber {get; set;}
    public String message {get; set;}
    public string stacktraceString {get; set;}
    public string typeName {get; set;}
    
    public FW_ExceptionWrapper(Exception ex) {
        this.cause = ex.getCause();
        this.lineNumber = ex.getLineNumber();
        this.stacktraceString = ex.getStackTraceString();
        this.message = ex.getMessage();
        this.typeName = ex.getTypeName(); 
    }

    /**
        * @description:    this static method is to create exception wrapper which could be either 
                            FW_DMLExceptionWrapper for DMl exception or FW_ExceptionWrapper(for any other exception)
    */
	public static FW_ExceptionWrapper exceptionWrapperFactory(Exception ex) {
        //to restrict a null ex
        System.assert(ex != null);
        
        string exceptionTypeName = formatExceptionTypeName(ex.getTypeName());
        
        return exceptionTypeName == 'DmlException' ? new FW_DMLExceptionWrapper((DMLException)ex) : new FW_ExceptionWrapper(ex);
	}

    /**
        * @description:    DML exception wrapper class
    */
    public class FW_DMLExceptionWrapper extends FW_ExceptionWrapper {

        public FW_DMLExceptionWrapper(DMLException ex) {
            super(ex);            
            final String dmlErrorMessagetemplate = 'for index - {0} and record id - {1} with the error message {2}';
            String[] stringList = new String[]{};
            for (integer i =0; i<ex.getNumDml(); i++) {

                stringList.add(String.format(dmlErrorMessagetemplate, 
                    new String [] {String.valueOf(ex.getDMLIndex(i)), ex.getDMLId(i), ex.getDMLMessage(i)}));
            }
            this.message = String.join(stringList, ',\n ');
        }
    }
    
    /**
        *  @description:    
    */
    public static string formatExceptionTypeName(string exceptionTypeName) {
        string[] exceptionName = exceptionTypeName.split('\\.');
        return exceptionName == null ? null : exceptionName.size() > 1 ? exceptionName[1]: exceptionName[0];
    }
}