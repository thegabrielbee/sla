/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle Milestone Criterias 
* in Entitlement Process
**/
public with sharing class MilestoneCriteria {
    private string objectName;
    private string field;
    private string operation;
    private string value;

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to handle the execution of
    * the batch the will create/update the Custom Setting Records
    * for the Entitlement Process
    * @param field the Milestone Criteria Field - Exemple: Case.Status
    * @param operation the Milestone Criteria operation - Example: equal, not equal to  
    * @param value the Milestone Criteria value - Example: New  
    **/
    public MilestoneCriteria(String field, String operation, String value) {
        this.objectName = field.split('\\.')[0];
        this.field = field.split('\\.')[1];
        this.operation = getOperationSymbol(operation);
        this.value = value; 
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to handle the transformation
    * of the current instance of Milestone Criterias to a Salesforce Formula
    **/
    public String toFormula() {
        String field = this.field;
        String value = this.value;
        Schema.SObjectType objectSchema = Schema.getGlobalDescribe().get(this.objectName);
        Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe().fields.getMap();
        Schema.DescribeFieldResult fieldDescribe = fieldMap.get(this.field).getDescribe();
        if (fieldDescribe.getType() == Schema.DisplayType.Picklist) {
            field = 'TEXT(' + field + ')';
            value = '\'' + value + '\'';
        }
        if (fieldDescribe.getType() == Schema.DisplayType.STRING) {
            value = '\'' + value + '\'';
        }

        return field + ' ' + this.operation + ' ' + value;
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to handle the transformation
    * of a List of Milestone Criteria instances into a Salesforce Formula
    * @param criterias list of Milestone Criteria instances
    **/
    public static String toFormula(List<MilestoneCriteria> criterias){
        String milestoneFormula = '';
        for(MilestoneCriteria each: criterias){
            if(milestoneFormula != ''){
                milestoneFormula += ' && ';
            }
            milestoneFormula += each.toFormula();
        }
        return milestoneFormula;
    }

    /** BeeGroup
    * @author Gabriel Nasicmento - gabriel.carva@protonmail.com
    * @description Method designed to map the criterias name to
    * their corresponding symbols
    * @param operationName the name of the Milestone Criteria Operation - Example: equal, not equal to  
    **/
    public String getOperationSymbol(String operationName) {
        String operationSymbol = '';
        switch on operationName {
            when 'equals' {
                operationSymbol = '=';
            }
            when 'not equal to' {
                operationSymbol = '!=';
            }
            when 'greaterThan' {
                operationSymbol = '>';
            }
            // IMPLEMENT THE OTHERS ELSE 
            when else {
                throw new AuraException('Condition Name not implemented: ' + operationName);
            }
        }
        return operationSymbol;
    }
}