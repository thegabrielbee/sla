trigger CaseTrigger on Case (after insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(Cases.class);
}