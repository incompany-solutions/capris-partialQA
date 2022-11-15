/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 15-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Schedule_DeleteEmailMessage implements Schedulable{
    public void execute(SchedulableContext ctx) {
        Batch_DeleteEmailMessage myBatchObject = new Batch_DeleteEmailMessage();
        Id batchId = Database.executeBatch(myBatchObject);
    }
}
