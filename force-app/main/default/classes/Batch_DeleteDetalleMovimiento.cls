/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteDetalleMovimiento implements Database.Batchable<sObject>, Database.Stateful{
    public List<Detalle_de_Movimiento__c> detalleMovimientoToDelete = new List<Detalle_de_Movimiento__c>();
    public List<Batch_ObjectStatusDMLHandler> successDetalleMovimientoDML = new List<Batch_ObjectStatusDMLHandler>();
    public List<Batch_ObjectStatusDMLHandler> errorDetalleMovimientoDML = new List<Batch_ObjectStatusDMLHandler>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        Date oneLessYear = Date.newInstance(now.Year()-1, now.Month(), now.Day());
        String strOneLessYear = String.valueOf(oneLessYear);
        System.debug('SELECT Id,Fecha_del_Movimiento__c FROM Detalle_de_Movimiento__c WHERE Fecha_del_Movimiento__c < '+strOneLessYear+' ORDER BY Fecha_del_Movimiento__c DESC');
        return DataBase.getQueryLocator(
            'SELECT Id,Fecha_del_Movimiento__c FROM Detalle_de_Movimiento__c WHERE Fecha_del_Movimiento__c < '+strOneLessYear+' ORDER BY Fecha_del_Movimiento__c DESC'
        );
    }
    public void execute(Database.BatchableContext bc, List<Detalle_de_Movimiento__c> records){
        Map<Id,Detalle_de_Movimiento__c> mapDetalleMovimientoToDelete = new map<Id,Detalle_de_Movimiento__c>();

        // process each batch of records
        for(Detalle_de_Movimiento__c emailToDelete : records)
        {
            detalleMovimientoToDelete.add(emailToDelete);
            mapDetalleMovimientoToDelete.put(emailToDelete.Id,emailToDelete);
        }
        
        Database.DeleteResult[] deleteResults = Database.delete(mapDetalleMovimientoToDelete.values(),false);
        Integer i=0;
        for(Database.DeleteResult databaseResult : deleteResults) {
            Batch_ObjectStatusDMLHandler statusObject = new Batch_ObjectStatusDMLHandler();
            if (databaseResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + databaseResult.getId());
                statusObject.objectSelected = (Detalle_de_Movimiento__c) mapDetalleMovimientoToDelete.get(databaseResult.getId());
                statusObject.status = 'SUCCESS';
                successDetalleMovimientoDML.add(statusObject);
            }
            else {
                // Operation failed, so get all errors  
                String strError = '';
                for(Database.Error err : databaseResult.getErrors()) {
                    strError += 'The following error has occurred: '+err.getStatusCode() + ': ' + err.getMessage()+':'+ err.getFields()+'\n';
                }
                statusObject.objectSelected = (Detalle_de_Movimiento__c) detalleMovimientoToDelete[i];
                statusObject.status = 'FAIL';
                statusObject.errorMessage = strError;

                errorDetalleMovimientoDML.add(statusObject);
            }
            i++;
        }
    }
    public void finish(Database.BatchableContext bc){

        Date today = Date.today();
        System.debug('Send Message');
        Blob successCVS = generateCSV(successDetalleMovimientoDML);
        Blob errorCVS = generateCSV(errorDetalleMovimientoDML);
        String strToday = today.Day()+'_'+today.Month()+'_'+today.Year();
        String csvSuccessName= 'Detalle_de_Movimiento__cSucess_'+strToday+'.csv';  
        String csvErrorName= 'Detalle_de_Movimiento__cFail_'+strToday+'.csv'; 
        String emailSubject = 'Resultados Detalle_de_Movimiento__c '+strToday;
        Batch_DeleteHelper.sendEmail(emailSubject,csvSuccessName,csvErrorName,successCVS,errorCVS);
        
    }
    @TestVisible
    private static Blob generateCSV(List<Batch_ObjectStatusDMLHandler> successDetalleMovimientoDML)
    {
        String header = 'ID, FECHAMOVIMIENTO, STATUS, MESSAGE \n';
        String finalstr = header ;
        for(Batch_ObjectStatusDMLHandler objectRecieved: successDetalleMovimientoDML)
        {
            Detalle_de_Movimiento__c actualDetalleMovimiento = (Detalle_de_Movimiento__c) objectRecieved.objectSelected;
            String recordString = actualDetalleMovimiento.Id+','+actualDetalleMovimiento.Fecha_del_Movimiento__c+','+objectRecieved.status+','+objectRecieved.errorMessage+'\n';

            finalstr = finalstr +recordString;

        }

        blob csvBlob = Blob.valueOf(finalstr);
        return csvBlob;
    }
}
