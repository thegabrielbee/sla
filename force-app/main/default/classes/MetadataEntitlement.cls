public with sharing class MetadataEntitlement {

    public static void finishMilestones(List<Case> cases, Map<Id, Case> oldCases) {
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