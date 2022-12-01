/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteDetalleMovimiento_Test {
    @TestSetup
    static void setup(){
        Detalle_de_Movimiento__c detalleDelete1 = TestData.createDetalleMovimiento(true,Date.newInstance(2020,1,1));
        Detalle_de_Movimiento__c detalleDelete2 = TestData.createDetalleMovimiento(true,Date.newInstance(2020,1,1));
        Detalle_de_Movimiento__c noDelete = TestData.createDetalleMovimiento(true,Date.newInstance(2022,1,1));
    }
        

    @isTest 
    static void test() {
        List<Detalle_de_Movimiento__c> detallesMovimiento = [SELECT Id FROM Detalle_de_Movimiento__c];
        System.assertEquals(3,detallesMovimiento.size());
        Test.startTest();
        Batch_DeleteDetalleMovimiento uca = new Batch_DeleteDetalleMovimiento();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        detallesMovimiento = [SELECT Id FROM Detalle_de_Movimiento__c];
        System.assertEquals(1, detallesMovimiento.size());
    }
}
