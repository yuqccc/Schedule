//
//  ZKScheduleModel.h
//  TeacherSystem
//
//  Created by yuqiang on 2018/3/5.
//  Copyright © 2018年 izhikang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Studentinfos;
@interface ZKScheduleModel : NSObject

@property (nonatomic, copy) NSString *classTypeName;

@property (nonatomic, copy) NSString *weekDay;

@property (nonatomic, copy) NSString *teacherDate;

@property (nonatomic, copy) NSString *teacherId;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *useClassType;

@property (nonatomic, copy) NSString *productName;

@property (nonatomic, copy) NSString *gradeName;

@property (nonatomic, assign) NSInteger isPassClass;

@property (nonatomic, strong) NSArray<Studentinfos *> *studentInfos;

@property (nonatomic, copy) NSString *schoolName;

@property (nonatomic, assign) NSInteger classModel;

@property (nonatomic, copy) NSString *gradeId;

@property (nonatomic, assign) NSInteger openStatus;

@property (nonatomic, copy) NSString *seatId;

@property(nonatomic ,assign) NSInteger timeGroup;

@property (nonatomic, copy) NSString *classTypeNameSub;

//请假中的新加的
@property(nonatomic ,assign) NSInteger canSelect;
@property (nonatomic, assign) NSInteger cellStatus;
@property (nonatomic, copy) NSString *tip;
@property (nonatomic, assign) BOOL hasSelected;
@property(nonatomic ,assign) NSInteger timeNumber;
@property (nonatomic, assign) BOOL isLeave;
//consume ：是否消耗课次 true 消耗课次 false 不消耗课次
@property(nonatomic ,assign) BOOL consume;
//2019-01-31 11:01:15新加，判断u状态是否为待支付
@property(nonatomic ,assign) NSInteger tablePayStatus;




@end

@interface Studentinfos : NSObject

@property (nonatomic, copy) NSString *schoolId;

@property (nonatomic, copy) NSString *useClassTypeId;

@property (nonatomic, copy) NSString *endTime;

@property (nonatomic, copy) NSString *studentId;

@property (nonatomic, copy) NSString *schoolName;

@property (nonatomic, copy) NSString *studentName;

@property (nonatomic, copy) NSString *useClassTypeName;

@property (nonatomic, copy) NSString *startTime;

@property (nonatomic, copy) NSString *classId;

@end


