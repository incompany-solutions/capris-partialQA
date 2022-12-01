/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 24-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Schedule_DeleteWebServiceLog implements Schedulable{
    public void execute(SchedulableContext ctx) {
        DeleteWebServiceLogController.evaluateWebServiceLog();
    }
}