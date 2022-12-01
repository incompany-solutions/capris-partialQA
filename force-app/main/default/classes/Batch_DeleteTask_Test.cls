/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteTask_Test {
    @TestSetup
    static void setup(){
        Task deleteTask1 = TestData.createTask(true);
        Task deleteTask2 = TestData.createTask(true);
        Task deleteNoTask = TestData.createTask(true);

        Test.setCreatedDate(deleteTask1.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(deleteTask2.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(deleteNoTask.Id,Date.newInstance(2022,1,1));
    }

    @isTest
    static void test(){
        List<Task> lstTasks = [SELECT Id FROM Task];
        System.assertEquals(3,lstTasks.size());

        Test.startTest();
        Batch_DeleteTask uca = new Batch_DeleteTask();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();

        lstTasks = [SELECT Id FROM Task];
        System.assertEquals(1,lstTasks.size());
    }
}
