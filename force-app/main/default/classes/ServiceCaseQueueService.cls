

public inherited sharing class ServiceCaseQueueService {

    private static final List<GroupMember> groups = [SELECT GroupId FROM GroupMember WHERE UserOrGroupId = :UserInfo.getUserId()];
    private static final List<Id> groupIds = addGroupIds(groups);

    @AuraEnabled(Cacheable=true)
    public static List<Case> getUserCases() {

        Integer numberOfRemainingRecords = 25;
        List<Case> finalListCases = new List<Case>();

        finalListCases.addAll(getUserCasesWithHighPriority());
        finalListCases.addAll(getUserCasesWithMediumPriority(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getUserCasesWithLowPriority(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getGroupCasesWithHighPriority(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getGroupCasesWithMediumPriority(numberOfRemainingRecords - finalListCases.size()));
        finalListCases.addAll(getGroupCasesWithLowPriority(numberOfRemainingRecords - finalListCases.size()));

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

    private static List<Case> getUserCasesWithHighPriority() {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'High' ORDER BY CreatedDate LIMIT 25];
    }

    private static List<Case> getUserCasesWithMediumPriority(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'Medium' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getUserCasesWithLowPriority(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId = :UserInfo.getUserId() AND Priority = 'Low' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getGroupCasesWithHighPriority(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'High' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getGroupCasesWithMediumPriority(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'Medium' ORDER BY CreatedDate LIMIT :casesLimit];
    }

    private static List<Case> getGroupCasesWithLowPriority(Integer casesLimit) {

        return [SELECT CaseNumber,OwnerId,Status,Priority,Origin FROM Case WHERE OwnerId IN :groupIds AND Priority = 'Low' ORDER BY CreatedDate LIMIT :casesLimit];
    }
}