/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 29-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class DeleteWebServiceLogController_Test {
    @TestSetup
    static void setup(){
        List<WebServiceLog__c> lstWebService = TestData.createWebService(true);
    }
    
    @isTest
    static void test(){
        List<WebServiceLog__c> lstWebService = [SELECT Id FROM WebServiceLog__c];
        System.assertEquals(102,lstWebService.size());

        Test.startTest();
        DeleteWebServiceLogController.evaluateWebServiceLog();
        Test.stopTest();

        lstWebService = [SELECT Id FROM WebServiceLog__c];
        System.assertEquals(0,lstWebService.size());
    }


}
