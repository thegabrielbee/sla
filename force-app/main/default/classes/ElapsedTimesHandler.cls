public with sharing class ElapsedTimesHandler {
    public void createElapsedTime(List<Case> cases, Map<Id, Case> oldCases) {
        Set<Id> entitlementIds = new Set<Id>();
        for(Case each: cases) {
            if(each.Entitlement == null){
                continue;
            }
            entitlementIds.add(each.EntitlementId);
        }
        
        Map<Id, Map<String, String>> mapConditions = new Map<Id, Map<String, String>>();
        List<MilestoneManagement__c> milestoneManagements = MilestoneManagement__c.getall().values();
        for(MilestoneManagement__c each: milestoneManagements) {
            if(mapConditions.get(each.EntitlementId__c) == null){
                mapConditions.put(each.EntitlementId__c, new Map<String, String>{ each.MilestoneName__c => each.MilestoneCriteriaFormula__c } );
            } else {
                mapConditions.get(each.EntitlementId__c).put(each.MilestoneName__c, each.MilestoneCriteriaFormula__c);
            }
        }

        Map<String, Set<Id>> milestoneToCaseIds = new Map<String, Set<Id>>();
        Set<Id> caseIds = new Set<Id>();
        for(Case each: cases) {
            Map<String, String> milestoneToCondition = mapConditions.get(each.EntitlementId);
            for(String milestonesName: milestoneToCondition.keySet()) {
                String milestoneCriterias = milestoneToCondition.get(milestonesName);
                FormulaEval.FormulaInstance createMilestone = Formula.builder()
                                .withReturnType(FormulaEval.FormulaReturnType.BOOLEAN)
                                .withType(Case.class)
                                .withFormula(milestoneCriterias)
                                .build();

                if(!((Boolean) createMilestone.evaluate(each) && !((Boolean) createMilestone.evaluate(oldCases.get(each.Id))))) {
                    continue;
                }
                caseIds.add(each.Id);
                if(milestoneToCaseIds.get(milestonesName) == null){
                    milestoneToCaseIds.put(milestonesName, new Set<Id>{ each.Id });
                } else {
                    milestoneToCaseIds.get(milestonesName).add(each.Id);
                }
            }   
        }

        if(caseIds.isEmpty()){
            return;
        }

        System.enqueueJob(new ElapsedTimesCreationQueueable(milestoneToCaseIds));
    }

    public void finishElapsedTime(List<CaseMilestone> milestones) {
        Map<Id, CaseMilestone> caseMilestonesIdToMilestones = new Map<Id, CaseMilestone>(milestones);
        Set<Id> caseIds = new Set<Id>();
        Set<Id> milestoneIds = new Set<Id>();
        for(CaseMilestone each: milestones){
            caseIds.add(each.CaseId);
            milestoneIds.add(each.Id);
        } 
        List<ElapsedTime__c> elapsedTimes = ((ElapsedTimesSelector) Injector.getInstance().instantiate(ElapsedTimesSelector.class)).selectElapsedTimesByCaseIdsAndMilestoneIdsAndIsCompleted(caseIds, milestoneIds, false);
        if(elapsedTimes == null || elapsedTimes.isEmpty()){
            return;
        }

        List<ElapsedTimeEvent__e> elapsedTimeEvents = new List<ElapsedTimeEvent__e>();  
        for(ElapsedTime__c each: elapsedTimes){
            each.CompletionDate__c = caseMilestonesIdToMilestones.get(each.Milestone__c).CompletionDate;
            elapsedTimeEvents.add(
                new ElapsedTimeEvent__e(
                    ElapsedTime__c = each.Id,
                    Case__c = each.Case__c,
                    Milestone__c = each.Milestone__c
                )
            );
        }
        ((DML) Injector.getInstance().instantiate(DML.class)).doUpdate(elapsedTimes);
        ((DML) Injector.getInstance().instantiate(DML.class)).doPublish(elapsedTimeEvents);
    }
}