trigger ElapsedTimeEventTrigger on ElapsedTimeEvent__e (after insert) {
    fflib_SObjectDomain.triggerHandler(ElapsedTimeEvents.class);
}