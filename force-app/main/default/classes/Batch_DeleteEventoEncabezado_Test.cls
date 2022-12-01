/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteEventoEncabezado_Test {
    @TestSetup
    static void setup(){
        EventoEncabezado__c eventoToDelete1 = TestData.createEventoEncabezado(true,Date.newInstance(2021,1,1));
        EventoEncabezado__c eventoToDelete2 = TestData.createEventoEncabezado(true,Date.newInstance(2021,1,1));
        EventoEncabezado__c eventoNoDelete = TestData.createEventoEncabezado(true,Date.newInstance(2022,1,1));
    }

    @isTest
    static void test(){
        List<EventoEncabezado__c> lstEventosEncabezado = [SELECT Id FROM EventoEncabezado__c];
        System.assertEquals(3,lstEventosEncabezado.size());

        Test.startTest();
        Batch_DeleteEventoEncabezado uca = new Batch_DeleteEventoEncabezado();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();

        lstEventosEncabezado = [SELECT Id FROM EventoEncabezado__c];
        System.assertEquals(1,lstEventosEncabezado.size());

    }
}
