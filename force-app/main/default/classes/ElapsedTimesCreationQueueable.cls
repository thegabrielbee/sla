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
        List<CaseMilestone> caseMilestones = [
                                                SELECT 
                                                    ID,
                                                    CASEID,
                                                    STARTDATE
                                                FROM 
                                                    CASEMILESTONE
                                                WHERE 
                                                    CASEID IN :caseIds 
                                                    AND MILESTONETYPE.NAME IN :milestoneToCaseIds.keySet() 
                                                    AND ISCOMPLETED = FALSE
                                            ];

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