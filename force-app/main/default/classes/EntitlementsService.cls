public with sharing class EntitlementsService extends fflib_SObjectDomain {
    public EntitlementsService(List<Entitlement> entitlements) {
        super(entitlements);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new EntitlementsService(sObjectList);
        }
    }

    public override void onApplyDefaults(){}
    
    public override void onAfterInsert() {
        List<Entitlement> entitlements = (List<Entitlement>) Records;
        saveEntitlement(entitlements);
    }

    public void saveEntitlement(List<Entitlement> entitlements) {
        List<String> entitlementNames = new List<String>();
        Map<String, Id> slaProcessNameToentitlementId = new Map<String, Id>();
        Set<Id> validEntitlementProcessIds = new Set<Id>(); 
        for(Entitlement each: entitlements){
            if(
                each.SlaProcessId == null || 
                (each.StartDate == null || each.StartDate > Date.today()) ||
                (each.EndDate == null || each.EndDate < Date.today())
            ) {
                continue;
            }
            validEntitlementProcessIds.add(each.Id);
         }
        if(validEntitlementProcessIds.isEmpty()){
            return;
        }
        
        System.enqueueJob(new MetadataEntitlementQueueable(validEntitlementProcessIds));
    }
}