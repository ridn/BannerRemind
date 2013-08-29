#import <UIKit/UIKit2.h>
#import "EventKit.h"

//Dat iOS 3 SDK...
@interface SBBulletinBannerItem
- (id)title;
- (id)message;
@end
@interface SBBulletinBannerView
- (id)initWithItem:(id)arg1;
- (id)bannerItem;
@end

%hook SBBulletinBannerView

- (id)initWithItem:(id)arg1
{
       if(self == %orig)
       {
	  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                             initWithTarget:self 
                                             action:@selector(handleLongPress:)];
        longPress.minimumPressDuration = 2.0;
        [self addGestureRecognizer:longPress];
        [longPress release];
       }
       return %orig; 
}
%new
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{

	if(UIGestureRecognizerStateBegan == sender.state) {
		//incomplete ;P
		//the minutes should be something set, not necessarily a fixed time!
		[self createReminderForMinutes:10 orOnDate:nil];
	}
     
}
%new
-(void)createReminderForMinutes:(NSUInteger)minutes orOnDate:(NSDate *)date{

    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder
                          completion:^(BOOL granted, NSError *error) {
                              EKReminder *reminder = [EKReminder reminderWithEventStore:store];
                              [reminder setTitle:[[self bannerItem] title]];
                              [reminder setNotes:[[self bannerItem] message]];

                              [reminder setCalendar:[store defaultCalendarForNewReminders]];
                              NSDate* alarmDate;
                              if(date == nil) alarmDate = [NSDate dateWithTimeIntervalSinceNow:minutes * 60];
								else {alarmDate = date;}
                              EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:alarmDate];
                              [reminder setDueDateComponents:[[NSCalendar currentCalendar] components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:alarmDate]];
                              [reminder setAlarms:[NSArray arrayWithObjects:alarm,nil]];
                              
                              NSError *err = nil;
                              BOOL didSave = [store saveReminder:reminder commit:YES error:&err];
                              [store release];
                              if (didSave == NO || err != nil) {
								NSString *body = @"Failed to create reminder!";
								[[InstaBanner alloc] showBannerWithBundleIdentifier:@"com.apple.reminders" title: @"Error" message:body];
                              }
                          }];
}

%end
