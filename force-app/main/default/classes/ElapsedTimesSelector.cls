public with sharing class ElapsedTimesSelector extends fflib_SObjectSelector {
    
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            ElapsedTime__c.Id,
            ElapsedTime__c.Case__c,
            ElapsedTime__c.CompletionDate__c,
            ElapsedTime__c.Milestone__c,
            ElapsedTime__c.IsCompleted__c
        };
    }
    
    public Schema.SObjectType getSObjectType(){
        return ElapsedTime__c.SObjectType;
    }

    public List<ElapsedTime__c> selectElapsedTimesByCaseIdsAndMilestoneIdsAndIsCompleted(Set<Id> caseIds, Set<Id> milestoneIds, Boolean isCompleted){
        return [
            SELECT
                COMPLETIONDATE__C,
                MILESTONE__C,
                CASE__C
            FROM
                ELAPSEDTIME__C
            WHERE
                CASE__C IN :caseIds
                AND MILESTONE__C IN :milestoneIds
                AND ISCOMPLETED__C = :isCompleted
        ];
    }

}