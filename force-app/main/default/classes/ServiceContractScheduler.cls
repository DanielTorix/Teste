/**
 * Created by mateuszbednarek on 27/03/2021.
 * System.schedule('Morning Data Load', '0 30 5 * * ? *' , new ServiceContractScheduler());
 * System.schedule('Afternoon Data Load', '0 30 17 * * ? *' , new ServiceContractScheduler());
 */

global with sharing class ServiceContractScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ServiceContractBatch serviceBatch = new ServiceContractBatch();
        Database.executeBatch(serviceBatch);
    }
}