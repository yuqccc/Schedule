//
//  ZKScheduleCell.m
//  TeacherSystem
//
//  Created by yuqiang on 2018/2/27.
//  Copyright © 2018年 izhikang. All rights reserved.
//

#import "ZKScheduleCell.h"
#import "UIColor+Helper.h"


#define ScheduleCellColorGray [UIColor hexStringToColor:@"F6F7F9"]
#define ScheduleCellColorWhite [UIColor hexStringToColor:@"FFFFFF"]
#define ScheduleCellColorBlue [UIColor hexStringToColor:@"62A8FC"]
#define ScheduleCellColorRed [UIColor hexStringToColor:@"F75E4A"]

#define ScheduleCellColorLightGray [UIColor hexStringToColor:@"F6F7F9"]
#define ScheduleCellColorLightGreen [UIColor hexStringToColor:@"22d3a5"]

#define ScheduleCellColorBlack [UIColor hexStringToColor:@"18191a"]




@interface ZKScheduleCell()

@property (weak, nonatomic) IBOutlet UILabel *title;

@end

@implementation ZKScheduleCell

-(void)setIsEmptyCell:(BOOL)isEmptyCell{
    _isEmptyCell = isEmptyCell;
    if (isEmptyCell) {
        self.title.backgroundColor = ScheduleCellColorLightGray;
        self.title.text = @"";
        self.title.textColor = ScheduleCellColorBlack;
    }
}

-(void)setScheduleModel:(ZKScheduleModel *)scheduleModel{
    _scheduleModel = scheduleModel;

    //请假
    if (scheduleModel.isLeave) {
        if (scheduleModel.timeGroup == 1 || scheduleModel.timeGroup == 3) {
            self.title.text = ((Studentinfos *)self.scheduleModel.studentInfos.firstObject).studentName;
        }else if (scheduleModel.timeGroup == 2){
            self.title.text = self.scheduleModel.classTypeName;
        }
        
        if (scheduleModel.hasSelected) {
            self.title.backgroundColor = ScheduleCellColorBlue;
            self.title.textColor = ScheduleCellColorWhite;

            //解决点击字体颜色变黑的问题
            switch (scheduleModel.cellStatus) {
                case 0:
                    self.title.textColor = ScheduleCellColorBlack;
                    break;
                case 1:
                    self.title.textColor = ScheduleCellColorWhite;
                    break;
                case 2:
                    self.title.textColor = ScheduleCellColorBlack;
                    break;
                default:
                    break;
            }

        }else{
            switch (scheduleModel.cellStatus) {
                case 0:
                    self.title.backgroundColor = ScheduleCellColorLightGreen;
                    self.title.text = @"";
                    self.title.textColor = ScheduleCellColorBlack;
                    break;
                case 1:
                    self.title.backgroundColor = ScheduleCellColorRed;
                    self.title.textColor = ScheduleCellColorWhite;
                    break;
                case 2:
                    self.title.backgroundColor = ScheduleCellColorGray;
                    self.title.text = @"";
                    self.title.textColor = ScheduleCellColorBlack;
                    break;
                default:
                    self.title.text = @"";
                    break;
            }
        }
        
        return;
    }
    
    //课表
    switch (scheduleModel.openStatus) {
        case 0:
            if (scheduleModel.hasSelected) {
                self.title.backgroundColor = [UIColor hexStringToColor:@"edeff0"];

            }else{
                self.title.backgroundColor = [UIColor hexStringToColor:@"F6F7F9"];
            }
            self.title.text = @"";
            self.title.textColor = ScheduleCellColorBlack;
            break;
        case 1:
        case 4:
            if (scheduleModel.hasSelected) {
                self.title.backgroundColor = [UIColor hexStringToColor:@"1ec79b"];
            }else{
                self.title.backgroundColor = ScheduleCellColorLightGreen;
            }
            self.title.text = @"";
            self.title.textColor = ScheduleCellColorBlack;
            break;
        case 2:
            if (scheduleModel.hasSelected) {
                self.title.backgroundColor = [UIColor hexStringToColor:@"e85440"];
            }else{
                self.title.backgroundColor = [UIColor hexStringToColor:@"ff5f4a"];
            }
            
            if (scheduleModel.classModel == 0) {
                self.title.text = ((Studentinfos *)self.scheduleModel.studentInfos.firstObject).studentName;
            }else{
                if ([self.scheduleModel.classTypeName containsString:@"在线"]) {
                    self.title.text = [NSString stringWithFormat:@"在线课\n(%ld)",scheduleModel.studentInfos.count];
                }else{
                    NSString *classTypeNameSub = @"";
                    if (self.scheduleModel.classTypeNameSub.length >= 3) {
                        classTypeNameSub = [self.scheduleModel.classTypeNameSub substringFromIndex:self.scheduleModel.classTypeNameSub.length - 3];
                    }else{
                        classTypeNameSub = self.scheduleModel.classTypeNameSub;
                    }
                    
                    self.title.text = [NSString stringWithFormat:@"%@\n(%ld)",classTypeNameSub,scheduleModel.studentInfos.count];
                }
            }
            self.title.textColor = ScheduleCellColorWhite;
            break;
        case 3:
            if (scheduleModel.hasSelected) {
                self.title.backgroundColor = [UIColor hexStringToColor:@"fcb54d"];
                
            }else{
                self.title.backgroundColor = [UIColor hexStringToColor:@"FDBA4F"];
            }
            self.title.text = @"已请假";
            self.title.textColor = ScheduleCellColorWhite;
            break;
        default:
            self.title.text = @"";
            self.title.textColor = ScheduleCellColorBlack;
            break;
    }
}


- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];

    
    if (self.scheduleModel.isLeave) {
        return;
    }
    
    
    if (selected) {
        switch (self.scheduleModel.openStatus) {
            case 0:
                self.title.backgroundColor = [UIColor hexStringToColor:@"edeff0"];
                break;
            case 1:
            case 4:
                self.title.backgroundColor = [UIColor hexStringToColor:@"1ec79b"];
                break;
            case 2:
                self.title.backgroundColor = [UIColor hexStringToColor:@"e85440"];
                break;
            case 3:
                self.title.backgroundColor = [UIColor hexStringToColor:@"fcb54d"];
                break;
            default:
                break;
        }
    }else{
        switch (self.scheduleModel.openStatus) {
            case 0:
                self.title.backgroundColor = [UIColor hexStringToColor:@"F6F7F9"];
                break;
            case 1:
            case 4:
                self.title.backgroundColor = [UIColor hexStringToColor:@"22d3a5"];
                break;
            case 2:
                self.title.backgroundColor = [UIColor hexStringToColor:@"ff5f4a"];
                break;
            case 3:
                self.title.backgroundColor = [UIColor hexStringToColor:@"fcb54d"];
                break;
            default:
                break;
        }

    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
@end
