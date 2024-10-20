public with sharing class MetadataEntitlementQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> validEntitlementProcessIds;

    public MetadataEntitlementQueueable(Set<Id> validEntitlementProcessIds) {
        this.validEntitlementProcessIds = validEntitlementProcessIds; 
    }

    public static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public void execute(QueueableContext context) {
        List<String> entitlementNames = new List<String>();
        Map<String, Id> slaProcessNameToentitlementId = new Map<String, Id>();
        List<Entitlement> entitlements = [SELECT SlaProcess.NameNorm FROM ENTITLEMENT WHERE ID IN :this.validEntitlementProcessIds];
        for(Entitlement each: entitlements){
            entitlementNames.add(each.SlaProcess.NameNorm);
            slaProcessNameToentitlementId.put(each.SlaProcess.NameNorm, each.Id);
        }
    
        MetadataService.MetadataPort service = createService();
        // MIGRATE THIS TO CACHE TO AVOID MULTIPLE QUERIES, AND UPDATE THE CACHE IN ENTITLEMENT TRIGGER
        List<MetadataService.EntitlementProcess> ennt = (List<MetadataService.EntitlementProcess>) service.readMetadata('EntitlementProcess', entitlementNames).getRecords();
        
        List<MilestoneManagement__c> mcs = new List<MilestoneManagement__c>();
        List<MilestoneManagement__c> mcsList = MilestoneManagement__c.getall().values();
        for(MetadataService.EntitlementProcess each: ennt){
            for (MetadataService.EntitlementProcessMilestoneItem mlItem: each.milestones) {
                List<MilestoneCondition> conditions = new List<MilestoneCondition>();
                for(MetadataService.FilterItem tmp: mlItem.milestoneCriteriaFilterItems){
                    conditions.add(new MilestoneCondition(tmp.field, tmp.operation, tmp.value));
                }
                mcs.add(
                    new MilestoneManagement__c(
                        Name=slaProcessNameToentitlementId.get(each.fullName) + mlItem.milestoneName + String.valueOf(mcsList.size()),
                        Id__c=slaProcessNameToentitlementId.get(each.fullName) + each.fullName + mlItem.milestoneName,
                        EntitlementDeveloperName__c=each.fullName,
                        MilestoneName__c=mlItem.milestoneName,
                        EntitlementId__c=slaProcessNameToentitlementId.get(each.fullName), 
                        MilestoneCriteriaFormula__c=MilestoneCondition.toFormula(conditions)
                    )
                );
            }
        }
        ((DML) Injector.getInstance().instantiate(DML.class)).doInsert(mcs);
    }
}