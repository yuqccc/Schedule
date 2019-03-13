//
//  ZKScheduleCell.h
//  TeacherSystem
//
//  Created by yuqiang on 2018/2/27.
//  Copyright © 2018年 izhikang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKScheduleModel.h"

@interface ZKScheduleCell : UICollectionViewCell
@property (nonatomic,strong)ZKScheduleModel *scheduleModel;
@property(nonatomic ,assign) BOOL isEmptyCell;



@end
