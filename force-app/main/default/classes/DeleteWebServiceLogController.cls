/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
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
        Integer cantidadRegistros = Test.isRunningTest()==false?550001:101;
        System.debug(numberWebServiceRegister);
        System.debug(cantidadRegistros);
        if(numberWebServiceRegister>cantidadRegistros)
        {
            Batch_DeleteWebServiceLog myBatchObject = new Batch_DeleteWebServiceLog();
            Database.executeBatch(myBatchObject);
        }
    }
}
