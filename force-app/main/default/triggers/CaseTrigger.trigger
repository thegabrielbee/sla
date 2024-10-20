trigger CaseTrigger on Case (after insert, before update, after update) {
    /**
     * 
     * 
    
    if(Trigger.isInsert)
        
    if(Trigger.isUpdate && Trigger.isBefore)
        cm.closeMilestone(Trigger.oldMap, Trigger.newMap);	
    if( Trigger.isUpdate && Trigger.isAfter)
    	System.debug('Trigger.isAfter');
    	cm.reopenMilestones(Trigger.oldMap, Trigger.newMap);
     */
    CaseMilestoneHandler cm = new CaseMilestoneHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        cm.assignEntitlement(Trigger.new);
    }
    
    if( Trigger.isUpdate && Trigger.isAfter){
        MetadataEntitlement.finishMilestones(trigger.new, trigger.oldMap);
    }
}