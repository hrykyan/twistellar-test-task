
global with sharing class AccountCasesPdfCtrl {

    public Date firstDate{get;set;}
    public List<Case> accountCases{get;set;}
    private Date currentDate = Date.today();
    private Date weekStart = currentDate.toStartOfWeek();
    private Date previousWeekEnd = previousWeekStart() + 10;

    public AccountCasesPdfCtrl() {
       this.firstDate = previousWeekStart();
       this.accountCases = getAccountCasesPrevWeek();
    }

    private Date previousWeekStart() {
        Date weekStart1 =  Date.newInstance(2022, 06, 09);
        if (currentDate == weekStart) {
            weekStart1 = weekStart - 13;
        } else {
            weekStart1 = weekStart - 6;
        }
        return weekStart1;
    }

    private List<Case> getAccountCasesPrevWeek() {
        List<Case> accountCases = [SELECT Account.Name, Account.Owner.Name, CaseNumber, Status, Priority, Origin FROM Case WHERE
        CreatedDate > :previousWeekStart() AND CreatedDate < :previousWeekEnd ORDER BY Account.Name NULLS LAST];
        return accountCases;
    }
}