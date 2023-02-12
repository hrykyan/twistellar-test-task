

public inherited sharing class ServiceCaseQueueService {

    private static final List<GroupMember> groups = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()];
    private static final List<Id> groupIds = addGroupIds(groups);

    @AuraEnabled(Cacheable=true)
    public static List<Case> getUserCases() {

        Integer numberOfRemainingRecords = 25;
        List<Case> finalListCases = new List<Case>();

        finalListCases.addAll(getUserCases1());
        finalListCases.addAll(getUserCases2(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getUserCases3(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getUserCases4(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getUserCases5(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getUserCases6(numberOfRemainingRecords - finalListCases.size()));

        return finalListCases;
    }

    @AuraEnabled
    public static void updateStatus(String status, Id caseId) {

        Case caseForUpdate = [SELECT Status FROM Case WHERE Id = :caseId];

        if (caseForUpdate != null) {
            caseForUpdate.Status = status;
            update caseForUpdate;
        }
    }

    private static List<Id> addGroupIds(List<GroupMember> groupMembers) {

        List<Id> groupIds = new List<Id>();
        for (GroupMember g : groupMembers) {
            groupIds.add(g.GroupId);
        }
        return groupIds;
    }

    private static List<Case> getUserCases1() {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'High' ORDER BY CreatedDate LIMIT 25];
    }

    private static List<Case> getUserCases2(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'Medium' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getUserCases3(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'Low' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getUserCases4(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'High' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getUserCases5(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'Medium' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getUserCases6(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'Low' ORDER BY CreatedDate LIMIT :casesLimit];
    }
}