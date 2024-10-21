
/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Entitlment
* and Milestones General Manipulations
**/
public with sharing class EntitlementsHandler {
    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to handle the conclusion of
    * the milestones that have to be concluded
    * @param cases the cases version to be commited
    * @param oldCases the current version of the cases
    **/
    public void finishMilestones(List<Case> cases, Map<Id, Case> oldCases) {
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

        Map<String, Set<Id>> milestoneToCases = new Map<String, Set<Id>>();
        Set<Id> caseIds = new Set<Id>();
        for(Case each: cases) {
            Map<String, String> milestoneToCondition = mapConditions.get(each.EntitlementId);
            for(String milestonesName: milestoneToCondition.keySet()) {
                String milestoneCriterias = milestoneToCondition.get(milestonesName);
                FormulaEval.FormulaInstance concludeMilestone = Formula.builder()
                                .withReturnType(FormulaEval.FormulaReturnType.BOOLEAN)
                                .withType(Case.class)
                                .withFormula(milestoneCriterias)
                                .build();

                if(!(!((Boolean) concludeMilestone.evaluate(each)) && ((Boolean) concludeMilestone.evaluate(oldCases.get(each.Id)))) ){
                    continue;
                }
                caseIds.add(each.Id);
                if(milestoneToCases.get(milestonesName) == null){
                    milestoneToCases.put(milestonesName, new Set<Id>{ each.Id });
                } else {
                    milestoneToCases.get(milestonesName).add(each.Id);
                }
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
        ((DML) Injector.getInstance().instantiate(DML.class)).doUpdate(caseMilestone);
        ((ElapsedTimesHandler) Injector.getInstance().instantiate(ElapsedTimesHandler.class)).finishElapsedTime(caseMilestone);
    }
}