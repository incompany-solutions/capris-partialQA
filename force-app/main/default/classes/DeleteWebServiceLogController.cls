/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 24-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class DeleteWebServiceLogController {
    public static void evaluateWebServiceLog()
    {
        Integer numberWebServiceRegister;
        AggregateResult[] lstAgreggateResults = [SELECT COUNT(Id) cantidadRegistros FROM WebServiceLog__c];
        for(AggregateResult result : lstAgreggateResults)
        {
            numberWebServiceRegister = (Integer) result.get('cantidadRegistros');    
        }
        if(numberWebServiceRegister>550000)
        {
            Batch_DeleteWebServiceLog myBatchObject = new Batch_DeleteWebServiceLog();
            Database.executeBatch(myBatchObject);
        }
    }
}
