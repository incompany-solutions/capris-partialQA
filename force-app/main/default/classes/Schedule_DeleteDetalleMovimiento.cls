/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 15-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Schedule_DeleteDetalleMovimiento implements Schedulable{
    public void execute(SchedulableContext ctx) {
        Batch_DeleteDetalleMovimiento myBatchObject = new Batch_DeleteDetalleMovimiento();
        Id batchId = Database.executeBatch(myBatchObject);
    }
}
