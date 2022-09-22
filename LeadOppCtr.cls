public with sharing class LeadOppCtr {
    public class OwnerInfoListWrapper{
        @AuraEnabled
        public Id id{get; set;}
        @AuraEnabled
        public String owner{get; set;}
        @AuraEnabled
        public Integer noOfLeads{get; set;}
        @AuraEnabled
        public Integer noOfOpps{get; set;}
        @AuraEnabled
        public Double convRate{get; set;}
        @AuraEnabled
        public DateTime maxDate{get; set;}
        @AuraEnabled
        public Double totalAmount{get; set;}
    }
    
    @AuraEnabled(cacheable=true)
    public static List<OwnerInfoListWrapper> getOwnerInfo(Date startDate, Date endDate){
        List<OwnerInfoListWrapper> ownerWrapper = new List<OwnerInfoListWrapper>();
        List<Lead> leads = [SELECT id, Name, Owner.Id, Owner.Name, DB_Created_Date_without_Time__c FROM Lead 
                            WHERE DB_Created_Date_without_Time__c >= :startDate];
        //We are sorting the opportunites according to their created date.
        List<Opportunity> opp = [SELECT Amount, closeDate, Owner.Id, Owner.Name, CreatedDate FROM Opportunity 
                                 WHERE StageName = 'Closed Won' AND CloseDate <= :endDate ORDER By CreatedDate DESC];
        System.debug(opp);
        Map<Id,String> ownerIds = getOwnerIds(leads,opp);
        Map<Id,Integer> leadCountMap = getLeadCount(leads);
        Map<Id,Integer> oppCountMap = getOppCount(opp); 
        Map<Id,Date> maxDateMap = getMaxDate(opp);
        Map<Id,Double> totalAmountMap = getTotalAmount(opp);
        System.debug(ownerIds);
        for(Id u: ownerIds.keySet()){
            OwnerInfoListWrapper ownerInfo = new OwnerInfoListWrapper();
            ownerInfo.id = u;
            ownerInfo.owner = ownerIds.get(u);
            if(leadCountMap.get(u) <> null){
           		ownerInfo.noOfLeads = leadCountMap.get(u);
            }else{
                ownerInfo.noOfLeads = 0;
            }
            if(oppCountMap.get(u) <> null){
            	ownerInfo.noOfOpps = oppCountMap.get(u);
            }else{
                ownerInfo.noOfOpps = 0;
            }
            ownerInfo.maxDate = maxDateMap.get(u);
            if(totalAmountMap.get(u) <> null){
            	ownerInfo.totalAmount = totalAmountMap.get(u);
            }else{
                ownerInfo.totalAmount = 0;
            }
            if(ownerInfo.noOfLeads <> 0){
                ownerInfo.convRate = (Double)ownerInfo.noOfOpps/(Double)ownerInfo.noOfLeads;
            }else{
                ownerInfo.convRate = 1;
            }
            ownerWrapper.add(ownerInfo);
        }
        //System.debug(maxDateMap); 
        System.debug(ownerWrapper);
        return ownerWrapper;
    }
    
    public static Map<Id,String> getOwnerIds(List<Lead> leads,List<Opportunity> opp){
        Map<Id,String> owners = new Map<Id,String>();
        for(Lead l: leads){
            owners.put(l.OwnerId,l.Owner.Name);
        }
        for(Opportunity o : opp){
            owners.put(o.OwnerId,o.Owner.Name);
        }
        return owners;
    }
    
    public static Map<Id,Integer> getLeadCount(List<Lead> leads){
        Map<Id,Integer> leadMap = new Map<Id,Integer>();
        for(Lead l: leads){
            if(leadMap.containsKey(l.OwnerId)){
                leadMap.put(l.OwnerId, leadMap.get(l.OwnerId)+1);
            }else{
                leadMap.put(l.OwnerId, 1);
            }
        }
        return leadMap;
    }
    
    public static Map<Id,Integer> getOppCount(List<Opportunity> opp){
        Map<Id,Integer> oppMap = new Map<Id,Integer>();
        for(Opportunity o: opp){
            if(oppMap.containsKey(o.OwnerId)){
                oppMap.put(o.OwnerId, oppMap.get(o.OwnerId)+1);
            }else{
                oppMap.put(o.OwnerId, 1);
            }
        }
        return oppMap;
    }
    
    public static Map<Id,Date> getMaxDate(List<Opportunity> opp){
        Map<Id,Date> dateMap = new Map<Id,Date>();
        for(Opportunity o: opp){
            //Opportunities are already sorted w.r.t created date. So first instance of the owner must be maxDate value.
            if(!dateMap.containsKey(o.OwnerId)){
                DateTime dateGmt = o.CreatedDate;
                dateGmt = dateGmt.addHours(5);
                dateGmt = dateGmt.addMinutes(30);
                dateMap.put(o.OwnerId, dateGmt.date());
                //System.debug(o.CreatedDate);
            }
        }
        System.debug(dateMap);
        return dateMap;
    }
    
    public static Map<Id,Double> getTotalAmount(List<Opportunity> opp){
        Map<Id,Double> oppMap = new Map<Id,Double>();
        for(Opportunity o: opp){
            if(oppMap.containsKey(o.OwnerId)){
                System.debug(oppMap.get(o.OwnerId)+'+'+o.Amount);
                if(o.Amount<>null){
                	oppMap.put(o.OwnerId, oppMap.get(o.OwnerId) + o.Amount);
                }
                //System.debug(oppMap);
            }else{
                if(o.Amount<>null){
                    oppMap.put(o.OwnerId, o.Amount);
                }else{
                    oppMap.put(o.OwnerId, 0);
                }          
            }
        }
        return oppMap;
    }
}