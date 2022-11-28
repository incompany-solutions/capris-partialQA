/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class DeleteWebServiceLogController_Test {
    @TestSetup
    static void setup(){
        List<WebServiceLog__c> lstWebService = new List<WebServiceLog__c>();
        for(Integer i = 0;i<102;i++)
        {
            WebServiceLog__c webServiceToDelete = new WebServiceLog__c();
            webServiceToDelete.Web_Services__c = 'Web Service a borrar '+i;
            
            lstWebService.add(webServiceToDelete);
        }

        insert lstWebService;
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
