public with sharing class CaseMilestonesSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            CaseMilestone.Id,
            CaseMilestone.StartDate,
            CaseMilestone.CompletionDate,
            CaseMilestone.isCompleted
        };
    }
    
    public Schema.SObjectType getSObjectType(){
        return CaseMilestone.SObjectType;
    }

    public List<CaseMilestone> selectCaseMilestonesByCaseIdsAndMilestypeNameAndIsCompleted(Set<Id> caseIds, Set<String> milestoneNames, Boolean isCompleted){
        return [
            SELECT 
                ID,
                CASEID,
                COMPLETIONDATE,
                MILESTONETYPE.NAME,
                STARTDATE
            FROM 
                CASEMILESTONE
            WHERE 
                CASEID IN :caseIds 
                AND MILESTONETYPE.NAME IN :milestoneNames 
                AND ISCOMPLETED = :isCompleted
        ];
    }

}