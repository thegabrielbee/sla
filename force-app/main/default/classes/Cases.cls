/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle the Case Object trigger actions
**/
public with sharing class Cases extends fflib_SObjectDomain  {
    Map<Id, List<Case>> identifierDomainMapping = new Map<Id, List<Case>>();
    Map<Id, Map<Id, Case>> identifierDomainMappingOld = new Map<Id, Map<Id, Case>>();

    public Cases(List<Case> objects) {
        super(objects);
        Configuration.disableTriggerCRUDSecurity();
        setIdentifierDomainMapping();
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> objects) {
            return new Cases(objects);
        }
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to separate cases by RecordTypeId
    **/
    private void setIdentifierDomainMapping(){
        this.identifierDomainMapping = new Map<Id, List<Case>>();
        this.identifierDomainMappingOld = new Map<Id, Map<Id, Case>>();
        Map<Id, Case> oldCases = (Map<Id, Case>) existingRecords;
        List<Case> cases = (List<Case>) Records;
        Case oldCase;
        
        for(Case each: cases) {
            List<Case> values = this.identifierDomainMapping.get(each.RecordTypeId);
            if(oldCases != null) {
                oldCase = oldCases.get(each.Id);
            } else {
                oldCase = null;
            }
            if(values == null) {
                values = new List<Case>();
                this.identifierDomainMapping.put(each.RecordTypeId, values);
                this.identifierDomainMappingOld.put(each.RecordTypeId, new Map<Id, Case>{ each.Id =>  oldCase});
            } else {
                this.identifierDomainMappingOld.get(each.RecordTypeId).put(each.Id, oldCase);
            }
            values.add(each);
        }
    }

    public override void onApplyDefaults(){}

    public override void onAfterUpdate(Map<Id, Sobject> existingRecords) {
        for(Id identifier: this.identifierDomainMapping.keySet()){
            List<Case> cases = this.identifierDomainMapping.get(identifier);
            Map<Id, Case> oldCases = this.identifierDomainMappingOld.get(identifier);
            fflib_SObjectDomain domain = CasesDomainFactory.getInstance().newDomain(identifier, cases);
            domain.onAfterUpdate(oldCases);
        }
    }
}