public with sharing class MilestoneCondition {
    private string objectName;
    private string field;
    private string operation;
    private string value;
    public MilestoneCondition(String field, String operation, String value) {
        this.objectName = field.split('\\.')[0];
        this.field = field.split('\\.')[1];
        this.operation = getConditionSymbol(operation);
        this.value = value; 
    }

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

    public static String toFormula(List<MilestoneCondition> conditions){
        String milestoneFormula = '';
        for(MilestoneCondition each: conditions){
            if(milestoneFormula != ''){
                milestoneFormula += ' && ';
            }
            milestoneFormula += each.toFormula();
        }
        return milestoneFormula;
    }

    public String getConditionSymbol(String conditionName) {
        String conditionSymbol = '';
        switch on conditionName {
            when 'equals' {
                conditionSymbol = '=';
            }
            when 'not equal to' {
                conditionSymbol = '!=';
            }
            when 'greaterThan' {
                conditionSymbol = '>';
            }
            // IMPLEMENT THE OTHERS ELSE 
            when else {
                throw new AuraException('Condition Name not implemented: ' + conditionName);
            }
        }
        return conditionSymbol;
    }
}