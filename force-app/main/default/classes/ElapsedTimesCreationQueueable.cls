public with sharing class ElapsedTimesCreationQueueable implements Queueable {
    Map<String, Set<Id>> milestoneToCaseIds;

    public ElapsedTimesCreationQueueable(Map<String, Set<Id>> milestoneToCaseIds) {
        this.milestoneToCaseIds = milestoneToCaseIds;
    }

    public void execute(QueueableContext context) {
        Set<Id> caseIds = new Set<Id>(); 
        for(String milestoneName: milestoneToCaseIds.keySet()){
            caseIds.addAll(milestoneToCaseIds.get(milestoneName));
        }
        List<CaseMilestone> caseMilestones = ((CaseMilestonesSelector) Injector.getInstance().instantiate(CaseMilestonesSelector.class)).selectCaseMilestonesByCaseIdsAndMilestypeNameAndIsCompleted(caseIds, milestoneToCaseIds.keySet(), false);
        if(caseMilestones == null || caseMilestones.isEmpty()){
            return;
        }

        List<ElapsedTime__c> elapsedTimes = new List<ElapsedTime__c>();
        for(CaseMilestone each: caseMilestones) {
            elapsedTimes.add(
                new ElapsedTime__c(
                    Case__c = each.CaseId,
                    Milestone__c = each.Id,
                    StartDate__c = each.StartDate
                )
            );
        }
        ((DML) Injector.getInstance().instantiate(DML.class)).doInsert(elapsedTimes);
    }
}