//
//  ZKDayCollCell.m
//  TeacherSystem
//
//  Created by yuqiang on 2018/2/27.
//  Copyright © 2018年 izhikang. All rights reserved.
//

#import "ZKDayCollCell.h"
#import "DateHelper.h"
#import "UIColor+Helper.h"

@interface ZKDayCollCell()
@property (weak, nonatomic) IBOutlet UILabel *week;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;


@end

@implementation ZKDayCollCell

-(void)setModel:(ZKDayCollModel *)model{
    _model = model;
    NSString *weekStr;
    switch (model.index.row) {
        case 0:
            weekStr = @"一";
            break;
        case 1:
            weekStr = @"二";
            break;
        case 2:
            weekStr = @"三";
            break;
        case 3:
            weekStr = @"四";
            break;
        case 4:
            weekStr = @"五";
            break;
        case 5:
            weekStr = @"六";
            break;
        case 6:
            weekStr = @"日";
            break;
        default:
            break;
    }
    self.week.text = weekStr;
    self.dateLab.text = [NSString stringWithFormat:@"%ld",[DateHelper day:model.date]];
    
    if (model.isToday){
        self.dateLab.textColor = [UIColor hexStringToColor:@"fe5700"];
        self.dateLab.font = [UIFont systemFontOfSize:14];
        self.week.textColor = [UIColor hexStringToColor:@"fe5700"];
    }else{
        self.dateLab.textColor = [UIColor hexStringToColor:@"7a7d80"];
        self.dateLab.font = [UIFont systemFontOfSize:12];
        self.week.textColor = [UIColor hexStringToColor:@"18191a"];

    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor hexStringToColor:@"ffffff"];
}

@end
