public with sharing class EntitlementsService extends fflib_SObjectDomain {
    public EntitlementsService(List<Entitlement> sObjects) {
        super(sObjects);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new EntitlementsService(sObjects);
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

    public void finishMilestones(List<Case> cases, Map<Id, Case> oldCases) {
        Set<Id> entitlementIds = new Set<Id>();
        for(Case each: cases) {
            if(each.Entitlement == null){
                continue;
            }
            entitlementIds.add(each.EntitlementId);
        }
        
        Map<Id, Map<String, String>> mapConditions = new Map<Id, Map<String, String>>();
        List<MilestoneManagement__c> mcs = MilestoneManagement__c.getall().values();
        for(MilestoneManagement__c each: mcs) {
            if(mapConditions.get(each.EntitlementId__c) == null){
                mapConditions.put(each.EntitlementId__c, new Map<String, String>{ each.MilestoneName__c => each.MilestoneCriteriaFormula__c } );
            } else {
                mapConditions.get(each.EntitlementId__c).put(each.MilestoneName__c, each.MilestoneCriteriaFormula__c);
            }
        }

        Map<String, Set<Id>> milestoneToCases = new Map<String, Set<Id>>();
        Set<Id> caseIds = new Set<Id>();
        for(Case each: cases) {
            Map<String, String> milestoneToCondition = mapConditions.get(each.EntitlementId);
            for(String k: milestoneToCondition.keySet()) {
                String milestoneConditions = milestoneToCondition.get(k);
                FormulaEval.FormulaInstance isItSuper = Formula.builder()
                                .withReturnType(FormulaEval.FormulaReturnType.BOOLEAN)
                                .withType(Case.class)
                                .withFormula(milestoneConditions)
                                .build();

                if(!(!((Boolean) isItSuper.evaluate(each)) && ((Boolean) isItSuper.evaluate(oldCases.get(each.Id)))) ){
                    continue;
                }
                caseIds.add(each.Id);
                milestoneToCases.put(k, new Set<Id>{ each.Id });
            }   
        }

        if(caseIds.isEmpty()){
            return;
        }

        List<CaseMilestone> caseMilestone = [SELECT CASEID, MILESTONETYPE.NAME, COMPLETIONDATE FROM CASEMILESTONE WHERE CASEID IN :caseIds AND ISCOMPLETED = FALSE AND MILESTONETYPE.NAME IN :milestoneToCases.keySet()];
        if(caseMilestone.isEmpty()){
            return;
        }
        for(CaseMilestone each: caseMilestone){
            if(!milestoneToCases.get(each.MilestoneType.Name).contains(each.CaseId)){
                continue;
            }
            each.CompletionDate = Datetime.now();
        }
        update caseMilestone;
    }
}