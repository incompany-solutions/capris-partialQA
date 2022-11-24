/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 16-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteEventoEncabezado implements Database.Batchable<sObject>, Database.Stateful{
    public List<EventoEncabezado__c> EventoEncabezadoToDelete = new List<EventoEncabezado__c>();
    public List<Batch_ObjectStatusDMLHandler> successEventoEncabezadoDML = new List<Batch_ObjectStatusDMLHandler>();
    public List<Batch_ObjectStatusDMLHandler> errorEventoEncabezadoDML = new List<Batch_ObjectStatusDMLHandler>();
    Integer i = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        Datetime oneLessYear = Datetime.newInstance(now.Year()-1, now.Month(), now.Day(), now.hour()+6, now.minute(), now.second());
        String strOneLessYear = String.valueOf(oneLessYear).replace(' ','T');
        System.debug('SELECT Id,,Fecha_de_evento__c FROM EventoEncabezado__c WHERE Fecha_de_evento__c < '+strOneLessYear+' ORDER BY Fecha_de_evento__c DESC');
        return DataBase.getQueryLocator(
            'SELECT Id,Fecha_de_evento__c FROM EventoEncabezado__c WHERE Fecha_de_evento__c < '+strOneLessYear+'Z ORDER BY Fecha_de_evento__c DESC'
        );
    }
    public void execute(Database.BatchableContext bc, List<EventoEncabezado__c> records){
        Map<Id,EventoEncabezado__c> mapEventoEncabezadoToDelete = new map<Id,EventoEncabezado__c>();

        // process each batch of records
        for(EventoEncabezado__c eventoToDelete : records)
        {
            EventoEncabezadoToDelete.add(eventoToDelete);
            mapEventoEncabezadoToDelete.put(eventoToDelete.Id,eventoToDelete);
        }
        
        Database.DeleteResult[] deleteResults = Database.delete(EventoEncabezadoToDelete,false);
        for(Database.DeleteResult databaseResult : deleteResults) {
            Batch_ObjectStatusDMLHandler statusObject = new Batch_ObjectStatusDMLHandler();
            if (databaseResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + databaseResult.getId());
                statusObject.objectSelected = (EventoEncabezado__c) mapEventoEncabezadoToDelete.get(databaseResult.getId());
                statusObject.status = 'SUCCESS';
                successEventoEncabezadoDML.add(statusObject);
            }
            else {
                // Operation failed, so get all errors  
                String strError = '';
                for(Database.Error err : databaseResult.getErrors()) {
                    strError += 'The following error has occurred: '+err.getStatusCode() + ': ' + err.getMessage()+':'+ err.getFields()+'\n';
                }
                statusObject.objectSelected = (EventoEncabezado__c) EventoEncabezadoToDelete[i];
                statusObject.status = 'FAIL';
                statusObject.errorMessage = strError;

                errorEventoEncabezadoDML.add(statusObject);
            }
            i++;
        }
    }
    public void finish(Database.BatchableContext bc){

        Date today = Date.today();
        System.debug('Send Message');
        Blob successCVS = generateCSV(successEventoEncabezadoDML);
        Blob errorCVS = generateCSV(errorEventoEncabezadoDML);
        String strToday = today.Day()+'_'+today.Month()+'_'+today.Year();
        String csvSuccessName= 'EventoEncabezadosSucess_'+strToday+'.csv';  
        String csvErrorName= 'EventoEncabezadoFail_'+strToday+'.csv'; 
        String emailSubject = 'Resultados Evento Encabezado  '+strToday;
        Batch_DeleteHelper.sendEmail(emailSubject,csvSuccessName,csvErrorName,successCVS,errorCVS);
        
    }
    @TestVisible
    private static Blob generateCSV(List<Batch_ObjectStatusDMLHandler> successEventoEncabezadoDML)
    {
        String header = 'ID, FECHAEVENTO, STATUS, MESSAGE \n';
        String finalstr = header ;
        for(Batch_ObjectStatusDMLHandler objectRecieved: successEventoEncabezadoDML)
        {
            EventoEncabezado__c actualEventoEncabezado = (EventoEncabezado__c) objectRecieved.objectSelected;
            String recordString = actualEventoEncabezado.Id+','+actualEventoEncabezado.Fecha_de_evento__c+','+objectRecieved.status+','+objectRecieved.errorMessage+'\n';

            finalstr = finalstr +recordString;

        }

        blob csvBlob = Blob.valueOf(finalstr);
        return csvBlob;
    }
}
