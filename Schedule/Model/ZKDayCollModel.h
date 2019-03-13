//
//  ZKDayCollModel.h
//  TeacherSystem
//
//  Created by yuqiang on 2018/3/2.
//  Copyright © 2018年 izhikang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ZKDayCollModel : NSObject
@property (nonatomic,strong)NSDate *date;
@property(nonatomic ,strong) NSIndexPath *index;
@property(assign,nonatomic)BOOL isToday;

@end
