/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 16-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Schedule_DeleteEventoEncabezado implements Schedulable{
    public void execute(SchedulableContext ctx) {
        Batch_DeleteEventoEncabezado myBatchObject = new Batch_DeleteEventoEncabezado();
        Id batchId = Database.executeBatch(myBatchObject);
    }
}
