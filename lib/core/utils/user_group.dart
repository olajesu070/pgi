class UserGroup { 
  final int userGroupId; 
  final int priority; 
  final String cssClass; 
  final String text; 
 
  UserGroup({required this.userGroupId, required this.priority, required this.cssClass, required this.text}); 
 
  static List<UserGroup> userGroups = [ 
    UserGroup(userGroupId: 1, priority: 0, cssClass: 'userBanner--primary', text: ''), 
    UserGroup(userGroupId: 2, priority: 0, cssClass: 'userBanner--primary', text: ''), 
    UserGroup(userGroupId: 3, priority: 1000, cssClass: 'userBanner--primary', text: ''), 
    UserGroup(userGroupId: 4, priority: 900, cssClass: '', text: ''), 
    UserGroup(userGroupId: 5, priority: 999999, cssClass: 'userBanner--lightGreen', text: 'Active PGI Member'), 
    UserGroup(userGroupId: 6, priority: 999000, cssClass: 'userBanner--boardMember', text: 'Board Member'), 
    UserGroup(userGroupId: 7, priority: 986000, cssClass: 'userBanner--siteCrew', text: 'Site Crew'), 
    UserGroup(userGroupId: 8, priority: 987000, cssClass: 'userBanner--security', text: 'Security'), 
    UserGroup(userGroupId: 9, priority: 986000, cssClass: 'userBanner userBanner--silver', text: 'Vending'), 
    UserGroup(userGroupId: 10, priority: 989000, cssClass: 'userBanner--fireMed', text: 'Fire/Medical'), 
    UserGroup(userGroupId: 11, priority: 999999, cssClass: 'userBanner userBanner--lightGreen', text: 'Lifetime PGI Member 🧨🔥🧨🔥🧨'), 
    UserGroup(userGroupId: 12, priority: 988000, cssClass: 'userBanner--safety', text: 'Safety'), 
    UserGroup(userGroupId: 14, priority: 1000000, cssClass: 'userBanner--grandmaster', text: '🎆 Grandmaster'), 
    UserGroup(userGroupId: 15, priority: 0, cssClass: 'userBanner--jpa', text: 'JPA'), 
    UserGroup(userGroupId: 16, priority: 0, cssClass: 'userBanner--membershipServices', text: 'Membership Services'), 
    UserGroup(userGroupId: 17, priority: 0, cssClass: 'userBanner--seminars', text: 'Seminars'), 
    UserGroup(userGroupId: 18, priority: 0, cssClass: 'userBanner--doc-trainer', text: 'DOC Trainer'), 
    UserGroup(userGroupId: 19, priority: 0, cssClass: 'userBanner userBanner--silver', text: 'In memoriam (RIP)⌛'), 
    UserGroup(userGroupId: 20, priority: 0, cssClass: 'userBanner userBanner--primary', text: ''), 
  ]; 
 
  static UserGroup getUserGroupById(int id) {
    return userGroups.firstWhere((group) => group.userGroupId == id);
  }

} 
