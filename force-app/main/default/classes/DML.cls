/** BeeGroup
* @author Gabriel Nasicmento - gabriel.carva@protonmail.com
* @description Class designed to handle DML Operations
**/
public with sharing class DML {
    public List<Database.DeleteResult> doDelete(List<SObject> objects){
        return Database.delete(objects);
    }
    public List<Database.DeleteResult> doDelete(List<SObject> objects, Boolean allOrNone){
        return Database.delete(objects, allOrNone);
    }

    public List<Database.SaveResult> doInsert(List<SObject> objects){
        return Database.insert(objects);
    }
    public List<Database.SaveResult> doInsert(List<SObject> objects, Boolean allOrNone){
        return Database.insert(objects, allOrNone);
    }

    public List<Database.SaveResult> doUpdate(List<SObject> objects){
        return Database.update(objects);
    }
    public List<Database.SaveResult> doUpdate(List<SObject> objects, Boolean allOrNone){
        return Database.update(objects, allOrNone);
    }

    public List<Database.UpsertResult> doUpsert(List<SObject> objects){
        return Database.upsert(objects);
    }
    public List<Database.UpsertResult> doUpsert(List<SObject> objects, Boolean allOrNone){
        return Database.upsert(objects);
    }
    public List<Database.UpsertResult> doUpsert(List<SObject> objects, Schema.SObjectField externalField, Boolean allOrNone){
        return Database.upsert(objects, externalField);
    }
    
    public List<Database.MergeResult> doMerge(SObject master, List<SObject> duplicates){
        return Database.merge(master, duplicates);
    }

    public List<Database.SaveResult> doPublish(List<SObject> objects){
        return EventBus.publish(objects);
    }
}