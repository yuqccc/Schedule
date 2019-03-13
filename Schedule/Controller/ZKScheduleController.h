//
//  ScheduleController.h
//  TeacherSystem
//
//  Created by yuqiang on 2017/6/12.
//  Copyright © 2017年 izhikang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ChangeDateType) {
    LeftWeek = 1,
    LeftMonth = 2,
    RightWeek = 3,
    RightMonth = 4,
    LeftToday = 5,
    RightToday = 6,
};
#define OneDay  (24*60*60*1)//一天的时间

@interface ZKScheduleController : UIViewController

@end
