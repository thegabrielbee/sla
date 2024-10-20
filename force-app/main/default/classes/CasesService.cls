public with sharing class CasesService extends fflib_SObjectDomain {
    public CasesService(List<Case> sObjects) {
        super(sObjects);
        Configuration.disableTriggerCRUDSecurity();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new CasesService(sObjects);
        }
    }

    public override void onApplyDefaults(){}
    
    public override void onAfterUpdate(Map<Id, Sobject> existingRecords) {
        List<Case> cases = (List<Case>) Records;
        Map<Id, Case> oldCases = (Map<Id, Case>) existingRecords;
        
        ((EntitlementsService) Injector.getInstance().instantiate(EntitlementsService.class)).finishMilestones(cases, oldCases);
    }
}