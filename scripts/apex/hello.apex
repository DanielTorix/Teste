String hour = String.valueOf(Datetime.now().hour());
String min = String.valueOf(Datetime.now().minute() + 2); 
String ss = String.valueOf(Datetime.now().second());

//parse to cron expression
String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';

Async_FPSInvoiceRemainderSchedule s = new Async_FPSInvoiceRemainderSchedule(); 
System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);