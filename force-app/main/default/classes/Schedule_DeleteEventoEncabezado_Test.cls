/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Schedule_DeleteEventoEncabezado_Test {
    @TestSetup
    static void setup(){
        EventoEncabezado__c eventoToDelete1 = TestData.createEventoEncabezado(true,Date.newInstance(2021,1,1));
        EventoEncabezado__c eventoToDelete2 = TestData.createEventoEncabezado(true,Date.newInstance(2021,1,1));
        EventoEncabezado__c eventoNoDelete = TestData.createEventoEncabezado(true,Date.newInstance(2022,1,1));
    }

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    @isTest
    static void ScheduleTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Schedule_DeleteEventoEncabezado',
            CRON_EXP,
            new Schedule_DeleteEventoEncabezado());
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}
