/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the  of creation
* the Custom Setting Records for the Entitlement Process
**/
public with sharing class MetadataEntitlementQueueable implements Queueable, Database.AllowsCallouts {
    private Set<Id> validEntitlementProcessIds;

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @param validEntitlementProcessIds Entitlement Ids to manipulate
    **/
    public MetadataEntitlementQueueable(Set<Id> validEntitlementProcessIds) {
        this.validEntitlementProcessIds = validEntitlementProcessIds; 
    }

    public void execute(QueueableContext context) {
        List<String> entitlementNames = new List<String>();
        Map<String, Id> slaProcessNameToentitlementId = new Map<String, Id>();
        List<Entitlement> entitlements = [SELECT SlaProcess.NameNorm FROM ENTITLEMENT WHERE ID IN :this.validEntitlementProcessIds];
        for(Entitlement each: entitlements){
            entitlementNames.add(each.SlaProcess.NameNorm);
            slaProcessNameToentitlementId.put(each.SlaProcess.NameNorm, each.Id);
        }
    
        MetadataService.MetadataPort service = MetadataFactory.createService();
        // MIGRATE THIS TO CACHE TO AVOID MULTIPLE QUERIES, AND UPDATE THE CACHE IN ENTITLEMENT TRIGGER
        List<MetadataService.EntitlementProcess> ennt = (List<MetadataService.EntitlementProcess>) service.readMetadata('EntitlementProcess', entitlementNames).getRecords();
        
        List<MilestoneManagement__c> mcs = new List<MilestoneManagement__c>();
        List<MilestoneManagement__c> mcsList = MilestoneManagement__c.getall().values();
        for(MetadataService.EntitlementProcess each: ennt){
            for (MetadataService.EntitlementProcessMilestoneItem mlItem: each.milestones) {
                List<MilestoneCriteria> conditions = new List<MilestoneCriteria>();
                for(MetadataService.FilterItem tmp: mlItem.milestoneCriteriaFilterItems){
                    conditions.add(new MilestoneCriteria(tmp.field, tmp.operation, tmp.value));
                }
                mcs.add(
                    new MilestoneManagement__c(
                        Name=slaProcessNameToentitlementId.get(each.fullName) + mlItem.milestoneName + String.valueOf(mcsList.size()),
                        Id__c=slaProcessNameToentitlementId.get(each.fullName) + each.fullName + mlItem.milestoneName,
                        EntitlementDeveloperName__c=each.fullName,
                        MilestoneName__c=mlItem.milestoneName,
                        EntitlementId__c=slaProcessNameToentitlementId.get(each.fullName), 
                        MilestoneCriteriaFormula__c=MilestoneCriteria.toFormula(conditions)
                    )
                );
            }
        }
        ((DML) Injector.getInstance().instantiate(DML.class)).doInsert(mcs);
    }
}