@isTest
public class LeadOppCtrTest {
    @testSetup
    static void setup(){
        List<Lead> leads = new List<lead>();
        //Inserted leads and Opportunities as default user.
        for(integer i=0;i<100;i++){
            leads.add(new Lead(LastName='testLead '+i,
                               Company='testCompany '+i,
                               Status = 'Open - Not Contacted'));
        }
        
        
        List<Opportunity> opps = new List<Opportunity>();
        for(integer i=0;i<20;i++){
            opps.add(new Opportunity(Name = 'testOpp '+ i,
                                     CloseDate = Date.valueOf('2022-10-09'),
                                     StageName = 'Closed Won',
                                     Amount = 30000+i*10));
        }
        //Inserted leads and opportunities as different user.
        //Hard coding Ids in test class is not best practice, but this is only method by which we can test for multiple users.
        for(integer i=100;i<180;i++){
            leads.add(new Lead(LastName='testLead '+i,
                               Company='testCompany '+i,
                               Status = 'Open - Not Contacted',
                               OwnerId = '0055g00000F4px2AAB'));
        }
        
        for(integer i=20;i<50;i++){
            opps.add(new Opportunity(Name = 'testOpp '+ i,
                                     CloseDate = Date.valueOf('2022-10-19'),
                                     StageName = 'Closed Won',
                                     Amount = 30000+i*10,
                                     OwnerId = '0055g00000F4px2AAB'));
        }
        
        insert leads;
        insert opps;
        
        
    }
    
    @isTest
    static void testGetOwnerInfo(){      
        test.startTest();
        LeadOppCtr.getOwnerInfo(Date.valueOf('2022-09-19'),Date.valueOf('2022-10-19'));
        test.stopTest();
    }
    
    @isTest
    static void testGetOwnerIds(){
        //Lead and Opportunities for new user, satisfying the filters.
        Lead newLead = new Lead(LastName='testLeadDifUser',
                                Company='testCompanyDifUser',
                                Status = 'Open - Not Contacted',
                                OwnerId = '0055g00000F4pJDAAZ');
        Opportunity newOpp = new Opportunity(Name = 'testOppDifUser',
                                             CloseDate = Date.valueOf('2022-10-19'),
                                             StageName = 'Closed Won',
                                             Amount = 30000,
                                             OwnerId = '0055g00000F4pJDAAZ');
        insert newLead;
        insert newOpp;
        List<Lead> leads = fetchLeads(Date.today());
        List<Opportunity> opp = fetchOpp(Date.valueOf('2022-10-19'));
        
        Map<Id,String> expectedVal = new Map<Id,String>();
        expectedVal.put('0055g000009klErAAI', 'Ishan Dushettiwar');
        expectedVal.put('0055g00000F4pJDAAZ', 'Sanskruti Upganlawar');
        expectedVal.put('0055g00000F4px2AAB', 'Shaurya Tundulwar');
        test.startTest();
        //Method Should return three users.
        System.assertEquals(expectedVal, LeadOppCtr.getOwnerIds(leads, opp));
        test.stopTest();
    }
    
    @isTest
    static void testGetLeadCount(){
        Map<Id,Integer> expectedVal = new Map<Id,Integer>();
        expectedVal.put('0055g000009klErAAI', 100);
        expectedVal.put('0055g00000F4px2AAB', 80);
        List<Lead> leads = fetchLeads(Date.today());
        test.startTest();
        //Method Should return number of leads per user.
        System.assertEquals(expectedVal, LeadOppCtr.getLeadCount(leads));
        test.stopTest();
    }
    
    @isTest
    static void testGetOppCount(){
        Map<Id,Integer> expectedVal = new Map<Id,Integer>();
        expectedVal.put('0055g000009klErAAI', 20);
        expectedVal.put('0055g00000F4px2AAB', 30);
        List<Opportunity> opp = fetchOpp(Date.valueOf('2022-10-19'));
        test.startTest();
        //Method Should return number of Opportunities per user.
        System.assertEquals(expectedVal, LeadOppCtr.getOppCount(opp));
        test.stopTest();
    }
    
    @isTest
    static void testGetTotalAmount(){
        Map<Id,Double> expectedVal = new Map<Id,Double>();
        expectedVal.put('0055g000009klErAAI', 601900.0);
        expectedVal.put('0055g00000F4px2AAB', 910350.0);
        
        //Add one Opportunity with different user without putting amount.
        Opportunity newOpp = new Opportunity(Name = 'testOppDiffUser',
                                     CloseDate = Date.valueOf('2022-10-09'),
                                     StageName = 'Closed Won',
                                     OwnerId = '0055g00000F4psVAAR');
        insert newOpp;
        List<Opportunity> opp = fetchOpp(Date.valueOf('2022-10-19'));
        expectedVal.put('0055g00000F4psVAAR', 0);
        test.startTest();
        //Method Should return user id with their total value of amount in opportunites.
        System.assertEquals(expectedVal, LeadOppCtr.getTotalAmount(opp));
        test.stopTest();
    }
    
    public static List<Lead> fetchLeads(Date testDate){
        return [SELECT id, Name, Owner.Id, Owner.Name, DB_Created_Date_without_Time__c FROM Lead 
                WHERE DB_Created_Date_without_Time__c >= :testDate];
    }
    public static List<Opportunity> fetchOpp(Date closeDateVal){
        return [SELECT Amount, closeDate, Owner.Id, Owner.Name, CreatedDate FROM Opportunity 
         WHERE StageName = 'Closed Won' AND CloseDate <= :closeDateVal ORDER By CreatedDate DESC];
             }
}