/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public with sharing class Schedule_DeleteDetalleMovimiento_Test {
    @TestSetup
    static void setup(){
        Detalle_de_Movimiento__c detalleDelete1 = TestData.createDetalleMovimiento(true,Date.newInstance(2020,1,1));
        Detalle_de_Movimiento__c detalleDelete2 = TestData.createDetalleMovimiento(true,Date.newInstance(2020,1,1));
        Detalle_de_Movimiento__c noDelete = TestData.createDetalleMovimiento(true,Date.newInstance(2022,1,1));
    }

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    @isTest
    static void ScheduleTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Schedule_DeleteDetalleMovimiento',
            CRON_EXP,
            new Schedule_DeleteDetalleMovimiento());
        // Stopping the test will run the job synchronously
        Test.stopTest();


    }
}
