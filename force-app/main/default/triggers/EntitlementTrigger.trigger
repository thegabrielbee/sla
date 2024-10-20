trigger EntitlementTrigger on Entitlement (after insert) {
    fflib_SObjectDomain.triggerHandler(Entitlements.class);
}