global  class UpdateContactRGCountScheduler implements Schedulable  {
    global void execute(SchedulableContext ctx) {
        UpdateContactRGCount updateRGCount = new UpdateContactRGCount();
        database.executebatch(updateRGCount);
        
    }
}