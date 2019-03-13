//
//  ScheduleController.m
//  TeacherSystem
//
//  Created by yuqiang on 2017/6/12.
//  Copyright © 2017年 izhikang. All rights reserved.
//

#import "ZKScheduleController.h"
#import "ZKDayCollCell.h"
#import "ZKTimeCell.h"
#import "ZKScheduleCell.h"
#import "ZKDayCollModel.h"
#import "ZKScheduleModel.h"
#import "NSString+Helper.h"
#import "DateHelper.h"
#import "UIView+Frame.h"
#import "UIColor+Helper.h"
#import "MJExtension.h"


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kOperationBtnWidth 40
#define kMarginW 40
#define kMarginH 80


@interface ZKScheduleController ()<UIScrollViewDelegate,UICollectionViewDataSource,UISearchControllerDelegate,UITableViewDataSource,UITableViewDelegate>
//主父视图
@property (weak, nonatomic) IBOutlet UITableView *leftMainTable;//主tableView
@property (weak, nonatomic) IBOutlet UIView *headerView;//table上的header
//主子视图
@property (weak, nonatomic) IBOutlet UIView *commandBg;
@property (weak, nonatomic) IBOutlet UICollectionView *weekCollectionV;//显示的星期
@property (weak, nonatomic) IBOutlet UITableView *timeTabV;//左侧的时间段
@property (weak, nonatomic) IBOutlet UIScrollView *scheduleScrV;//课表滑动scrollView
@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollV;//课表
@property (weak, nonatomic) IBOutlet UICollectionView *beforeCollV;//左侧CollV
@property (weak, nonatomic) IBOutlet UICollectionView *behindCollV;//右侧CollV
@property (weak, nonatomic) IBOutlet UILabel *weekTitle;//课表第一行中间位置的标题
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *transferBtn;
@property (weak, nonatomic) IBOutlet UIButton *leaveBtn;
@property (weak, nonatomic) IBOutlet UIButton *prebookBtn;


//时段信息
@property (weak, nonatomic) IBOutlet UIView *classBgV;
@property (weak, nonatomic) IBOutlet UILabel *classLab;
@property (weak, nonatomic) IBOutlet UIView *infoBgV;
@property (weak, nonatomic) IBOutlet UIButton *classDateBtn;//日期
@property (weak, nonatomic) IBOutlet UIButton *classTimeBtn;//时间
@property (weak, nonatomic) IBOutlet UIButton *placeClassBtn;//地点
@property (weak, nonatomic) IBOutlet UILabel *nameClassLab;//最下面那个显示名字的lab
@property (weak, nonatomic) IBOutlet UIButton *placeTipBtn;//多校区
@property (nonatomic,strong)UIView *placeTipBg;
@property (weak, nonatomic) IBOutlet UILabel *waitPay;

//布局
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *beforeScheduleFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *behindScheduleFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *scheduleFlowLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *weekFlowLayout;
//数据源
@property (nonatomic,strong)NSMutableArray<ZKDayCollModel *> *weekArrM;
@property (nonatomic,strong)NSMutableArray *timeSheetList;//接口返回的timeSheetList
@property (nonatomic,strong)NSMutableArray *timeArrM;//课表左侧时间列表的的数据源
//约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scheduleBacHeight;//课表背景视图的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *beforeCollVWidth;//课表的CollV宽度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scheduleTop;
//计时器
@property (nonatomic,strong)NSTimer *timer;
//其他
@property (nonatomic,strong)NSDate *currentDate;//当前时间
@property (nonatomic,copy)NSString *termWeekName;//冬季第2周
@property(nonatomic ,assign) CGFloat headerHeight;
@property (nonatomic,strong)UICollectionViewCell *cell;
@property(nonatomic ,assign) BOOL isClear;//控制课表cell是否显示灰色
@property(nonatomic ,assign) ChangeDateType type;//切换日期时候用到的
@property(nonatomic ,assign) __block BOOL isRequest;

@property (nonatomic,copy)NSString *schools;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeTabW;

@end

@implementation ZKScheduleController

#pragma mark- Setter
-(void)setIsClear:(BOOL)isClear{
    _isClear = isClear;
    if (!isClear) {//滑动后触发课表reloadData，在最后一个灰色cell创建完成之后触发请求
        switch (self.type) {
            case LeftWeek:
                [self beforeWeek:nil];
                break;
            case LeftMonth:
                [self beforeMonth:nil];
                break;
            case RightWeek:
                [self afterWeek:nil];
                break;
            case RightMonth:
                [self afterMonth:nil];
                break;
            default:
                break;
        }
    }
}

#pragma mark- Getter
-(NSMutableArray *)timeArrM{
    if (_timeArrM == nil) {
        _timeArrM = [[NSMutableArray alloc]init];
    }
    
    [_timeArrM removeAllObjects];
    NSArray *arr = self.timeSheetList.firstObject;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZKScheduleModel *model = obj;
        NSArray *arr = [model.time componentsSeparatedByString:@"-"];
        [_timeArrM addObject:[NSString stringWithFormat:@"%ld\n%@",(idx+1),arr.firstObject]];
    }];
    return _timeArrM;
}

-(NSMutableArray *)timeSheetList{
    if (_timeSheetList == nil) {
        _timeSheetList = [[NSMutableArray alloc]init];
    }
    return _timeSheetList;
}

-(NSMutableArray *)weekArrM{
    if (_weekArrM == nil) {
        _weekArrM = [[NSMutableArray alloc]init];
    }
    return _weekArrM;
}

#pragma mark- LifeCycle
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;

    [self setNumberArray:[NSDate date]];
    [self registerNib];
    [self request];
    [self setupUI];
}

-(void)request{
    
    
    NSString *str = @"{\"ret\":true,\"msg\":\"查询成功\",\"data\":{\"timeSheetList\":[[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"08:00-10:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"10:10-12:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"13:00-15:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"15:10-17:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"18:00-20:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-11\",\"time\":\"21:00-23:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周一\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"08:00-10:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"10:10-12:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"13:00-15:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"15:10-17:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"18:00-20:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-12\",\"time\":\"21:00-23:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周二\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"08:00-10:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"10:10-12:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"13:00-15:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"15:10-17:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"18:00-20:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-13\",\"time\":\"21:00-23:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"在线课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周三\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"08:00-10:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"10:10-12:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"13:00-15:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"15:10-17:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"18:00-20:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-14\",\"time\":\"21:00-23:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"在线课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周四\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"08:00-10:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"10:10-12:10\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"13:00-15:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"15:10-17:10\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"18:00-20:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-15\",\"time\":\"21:00-23:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周五\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"08:00-10:00\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初一\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"初一英语冬季精品长期课\",\"seatId\":\"ff808081545d30360154651f1dbf7ca0\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"08:00:00\",\"endTime\":\"10:00:00\",\"studentId\":\"ff80808161229c490161321366890112\",\"studentName\":\"数学\",\"stuId\":\"ff80808161229c490161321366890112\",\"stuName\":\"数学\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"35422018112515232386401975885\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"10:10-12:10\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初二\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"初二英语冬季精品长期课\",\"seatId\":\"ff808081545d30360154651f1e097caa\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"10:10:00\",\"endTime\":\"12:10:00\",\"studentId\":\"ff8080815f7fe98f015f9ab6c9d75294\",\"studentName\":\"化学\",\"stuId\":\"ff8080815f7fe98f015f9ab6c9d75294\",\"stuName\":\"化学\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"16512018112310124383301947962\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"13:00-15:00\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"高一\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"高一英语冬季精品长期课\",\"seatId\":\"ff8080813f9fd3c2013fa326cff30a8d\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"13:00:00\",\"endTime\":\"15:00:00\",\"studentId\":\"ff8080815139d01a0151516aeaf478a1\",\"studentName\":\"语文\",\"stuId\":\"ff8080815139d01a0151516aeaf478a1\",\"stuName\":\"语文\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"07212018112310162333201949083\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"15:10-17:10\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初三\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"初三英语冬季精品长期课\",\"seatId\":\"ff8080812e9d2a2e012eb2db395548df\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"15:10:00\",\"endTime\":\"17:10:00\",\"studentId\":\"ff808081643b0fed01643bf9812c0242\",\"studentName\":\"劳动\",\"stuId\":\"ff808081643b0fed01643bf9812c0242\",\"stuName\":\"劳动\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"11212018120110050272302523866\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"18:00-20:00\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初二\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"初二英语冬季精品长期课\",\"seatId\":\"ff8080813f9fd3c2013fa32460120a75\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"18:00:00\",\"endTime\":\"20:00:00\",\"studentId\":\"ff80808163d369140163d85cfc94049f\",\"studentName\":\"思想品德\",\"stuId\":\"ff80808163d369140163d85cfc94049f\",\"stuName\":\"思想品德\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"77522018112310152397301947361\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-16\",\"time\":\"21:00-23:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周六\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}],[{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"08:00-10:00\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":1,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"10:10-12:10\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初三\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"初三英语冬季精品长期课\",\"seatId\":\"ff8080813f9fd3c2013fa32460120a75\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":2,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"10:10:00\",\"endTime\":\"12:10:00\",\"studentId\":\"ff80808164a893ed0164baf536155e59\",\"studentName\":\"物理\",\"stuId\":\"ff80808164a893ed0164baf536155e59\",\"stuName\":\"物理\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"80842018112310140762501725764\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"13:00-15:00\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"高二\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"高二英语冬季精品长期课\",\"seatId\":\"ff8080813005d566013011158af9173a\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":3,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"13:00:00\",\"endTime\":\"15:00:00\",\"studentId\":\"ff80808165d289490165e68bcc3e1ef6\",\"studentName\":\"历史\",\"stuId\":\"ff80808165d289490165e68bcc3e1ef6\",\"stuName\":\"历史\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"12252018112310154424902521879\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"15:10-17:10\",\"openStatus\":1,\"useClassType\":\"\",\"classTypeName\":\"常规课程,精品课程,活动课\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":4,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"18:00-20:00\",\"openStatus\":2,\"useClassType\":\"82822017110310415130759477138\",\"classTypeName\":\"精品课程\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"初三\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"初三英语冬季精品长期课\",\"seatId\":\"ff8080813005d5660130112ed90b1900\",\"classTypeNameSub\":\"标准课\",\"timeGroup\":\"3\",\"timeNumber\":5,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":2,\"studentInfos\":[{\"startTime\":\"18:00:00\",\"endTime\":\"20:00:00\",\"studentId\":\"ff8080815c35bfce015c38a6feb013da\",\"studentName\":\"政治\",\"stuId\":\"ff8080815c35bfce015c38a6feb013da\",\"stuName\":\"政治\",\"schoolId\":\"c1c65ee2-400f-11e0-9f72-e41f1361\",\"schoolName\":\"附中\",\"classId\":\"78372018112310431547801971194\",\"useClassTypeId\":\"82822017110310415130759477138\",\"useClassTypeName\":\"精品课程\",\"payStatus\":1}]},{\"teacherId\":\"aaaaaaaa073115060770301346902\",\"schoolName\":\"附中\",\"teacherDate\":\"2019-03-17\",\"time\":\"21:00-23:00\",\"openStatus\":0,\"useClassType\":\"\",\"classTypeName\":\"\",\"isPassClass\":0,\"gradeId\":\"\",\"gradeName\":\"\",\"classModel\":0,\"weekDay\":\"周日\",\"productName\":\"\",\"seatId\":\"\",\"classTypeNameSub\":\"\",\"timeGroup\":\"3\",\"timeNumber\":6,\"canSelect\":\"\",\"cellStatus\":\"\",\"tip\":\"\",\"consume\":\"\",\"tablePayStatus\":0,\"studentInfos\":[]}]],\"termWeekName\":\"冬季第3周\"},\"errcode\":0}";
    
    
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    
    


    NSArray *dataArr = [dictionary valueForKey:@"data"];
    NSArray *tmpWeek = [dataArr valueForKey:@"timeSheetList"];

    if (tmpWeek.count) {

        [self.timeSheetList removeAllObjects];
        for (int i = 0; i < tmpWeek.count ; i++) {
            NSArray *tmpDay = tmpWeek[i];
            NSArray *tmpDayModel = [ZKScheduleModel mj_objectArrayWithKeyValuesArray:tmpDay];
            for (ZKScheduleModel *model in tmpDayModel) {
                model.isLeave = NO;
            }
            [self.timeSheetList addObject:tmpDayModel];
        }
        self.termWeekName = [dataArr valueForKey:@"termWeekName"];

    }
    
    [self refreshUI];

    
}

#pragma mark- UI
-(void)setupUI{
    self.isRequest = NO;
    self.timeTabW.constant = 53;
    self.weekFlowLayout.itemSize = CGSizeMake((kScreenWidth - (self.timeTabW.constant+1) - 6)/7 , 50);
    self.scheduleFlowLayout.itemSize = CGSizeMake((kScreenWidth - (self.timeTabW.constant+1)  - 6)/7 , 40);
    self.beforeScheduleFlowLayout.itemSize = self.scheduleFlowLayout.itemSize;
    self.behindScheduleFlowLayout.itemSize = self.scheduleFlowLayout.itemSize;
    
    self.scheduleScrV.contentSize = CGSizeMake((kScreenWidth - (self.timeTabW.constant+1) ) * 3, 0);
    CGPoint offset = CGPointMake(kScreenWidth - (self.timeTabW.constant+1) , 0);
    self.scheduleScrV.contentOffset = offset;
    
    self.beforeCollVWidth.constant = kScreenWidth - (self.timeTabW.constant+1) ;
    
    //下拉刷新
//    self.leftMainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(request)];
}

-(void)registerNib{
    [self.weekCollectionV registerNib:[UINib nibWithNibName:@"ZKDayCollCell" bundle:nil] forCellWithReuseIdentifier:@"ZKDayCollCellID"];
    [self.timeTabV registerNib:[UINib nibWithNibName:@"ZKTimeCell" bundle:nil] forCellReuseIdentifier:@"ZKTimeCellID"];
    [self.scheduleCollV registerNib:[UINib nibWithNibName:@"ZKScheduleCell" bundle:nil] forCellWithReuseIdentifier:@"ZKScheduleCellID"];
    [self.beforeCollV registerNib:[UINib nibWithNibName:@"ZKScheduleCell" bundle:nil] forCellWithReuseIdentifier:@"ZKScheduleCellID"];
    [self.behindCollV registerNib:[UINib nibWithNibName:@"ZKScheduleCell" bundle:nil] forCellWithReuseIdentifier:@"ZKScheduleCellID"];

}

-(void)refreshUI{
    //回到中间的那个collV
    CGPoint offset = CGPointMake(kScreenWidth - (self.timeTabW.constant+1) , 0);
    [self.scheduleScrV setContentOffset:offset animated:NO];
    
    self.headerView.hidden = NO;
    self.classBgV.hidden = YES;
    self.infoBgV.hidden = YES;
    
    NSString *startStr = [DateHelper getMonthAndDayWithDate:((ZKDayCollModel *)self.weekArrM.firstObject).date];
    NSString *endStr = [DateHelper getMonthAndDayWithDate:((ZKDayCollModel *)self.weekArrM.lastObject).date];
    if ([self.termWeekName isEqualToString:@"未开放"]) {
        self.weekTitle.text = [NSString stringWithFormat:@"%@-%@",startStr,endStr];
    }else{
        self.weekTitle.text = [NSString stringWithFormat:@"%@ %@-%@",self.termWeekName,startStr,endStr];
    }
    
    [self.timeTabV reloadData];
    [self.scheduleCollV reloadData];
    [self.beforeCollV reloadData];
    [self.behindCollV reloadData];
    
    self.scheduleBacHeight.constant = 50 + 41*((NSArray *)self.timeSheetList[0]).count;
    
    CGRect parentRect = [self.view convertRect:self.infoBgV.frame fromView:self.infoBgV.superview];
    self.headerView.h = CGRectGetMaxY(parentRect);
    [self.leftMainTable reloadData];
    
}

#pragma mark- Request

#pragma mark- DateFunc
-(void)setNumberArray:(NSDate *)date{
    self.currentDate = date;
    NSInteger index = [[self weekdayStringFromDate:date] integerValue];
    NSDate* monday=[NSDate date];
    if (index-1>=0) {
        monday = [[NSDate alloc] initWithTimeInterval:-OneDay*(index-1) sinceDate:date];
    }
    //    NSMutableArray *afterArray = [NSMutableArray new];//本周内当天之后的日期
    
    for (int i=0; i<7;i++) {
        NSDate* theDate = [[NSDate alloc] initWithTimeInterval:+OneDay*i sinceDate:monday];
        ZKDayCollModel *model = [[ZKDayCollModel alloc] init];
        model.date = theDate;
        if ([[self getCurrentDay:theDate] isEqualToString:[self getCurrentDay:[NSDate date]]] ) {
            model.isToday = YES;
        }else{
            model.isToday = NO;
            
        }
        [self.weekArrM addObject:model];
    }
}

- (NSString*)weekdayStringFromDate:(NSDate*)inputDate {
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"7", @"1", @"2", @"3", @"4", @"5", @"6", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Beijing"];
    
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    return [weekdays objectAtIndex:theComponents.weekday];
}

-(NSString*)getCurrentDay:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //现在时间,你可以输出来看下是什么格式
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:date];
    
    //    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
}

#pragma mark- Action
- (void)hideTip:(id)sender {
    self.placeTipBg.hidden = YES;
    [self.timer invalidate];
}
- (IBAction)clickPlace:(id)sender {
    self.placeTipBg.hidden = NO;
    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(hideTip:) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

-(UIView *)placeTipBg{
    if (!_placeTipBg) {
        _placeTipBg = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:_placeTipBg];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTip:)];
        [_placeTipBg addGestureRecognizer:tap];
    
        CGRect rect = [self.view convertRect:self.placeTipBtn.frame fromView:self.placeTipBtn.superview];

        UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Tr"]];
        
        img.w = 19;
        img.h = 9;
        img.center = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect) - 5);
        [_placeTipBg addSubview:img];
        
        UIButton *btn = [[UIButton alloc]init];
        btn.titleLabel.numberOfLines = 0;
        [btn setBackgroundImage:[UIImage imageNamed:@"bj"] forState:UIControlStateNormal];
        [_placeTipBg addSubview:btn];
        NSString *str = [NSString stringWithFormat:@"%@",self.schools];
        [btn setTitle:str forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor hexStringToColor:@"ffffff"] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = 3;
        
        CGFloat w = [NSString widthtOfString:str fontSize:16 height:25];
        btn.h = 50;
        btn.w = w + 50;
        if (btn.w > kScreenWidth - 15*2) {
            btn.w = kScreenWidth - 15*2;
            btn.h = [NSString heightOfString:str fontSize:16 width:btn.w] + 20;
        }
        btn.x = kScreenWidth - btn.w - 15;
        btn.y = CGRectGetMinY(img.frame) - btn.h;
        btn.userInteractionEnabled = NO;
    }
    return _placeTipBg;
}

- (IBAction)clcikToday:(id)sender {
        int compareDate = [DateHelper compareOneDay:[NSDate date] withAnotherDay:self.currentDate];
    
    switch (compareDate) {
        case 1:
            [self scrollEffect:LeftToday];
            break;
            
        case -1:
            [self scrollEffect:LeftToday];
            break;
        default:
            break;
    }
    
    [self.weekArrM removeAllObjects];
    [self setNumberArray:[NSDate date]];
    [self.weekCollectionV reloadData];
//    [self requestGetTimeTable];

}

-(void)switchWeek{
    [self.weekArrM removeAllObjects];
    [self setNumberArray:self.currentDate];
    [self.weekCollectionV reloadData];
//    [self requestGetTimeTable];
}

-(void)scrollEffect:(ChangeDateType)type{
    self.type = type;
    CGFloat offsetX;
    switch (type) {
        case LeftWeek:
        case LeftMonth:
        case LeftToday:
            offsetX = 0;
            break;
        case RightWeek:
        case RightMonth:
        case RightToday:
            offsetX = (kScreenWidth - (self.timeTabW.constant+1) )*2;
            break;
        default:
            offsetX = 0;
            break;
    }
    CGPoint offset = CGPointMake(offsetX, 0);
    [self.scheduleScrV setContentOffset:offset animated:YES];
    [self clearScheduleCollV];
}

- (IBAction)beforeMonth:(id)sender {
    if (sender) {//点击切换月和周的按钮
        [self scrollEffect:LeftMonth];
    }
    if (!sender) {
        self.currentDate = [[NSDate alloc] initWithTimeInterval:-OneDay*7*4 sinceDate:self.currentDate];
        [self switchWeek];
    }
}
- (IBAction)beforeWeek:(id)sender {
    if (sender) {
        [self scrollEffect:LeftWeek];
    }
    if (!sender) {
        self.currentDate = [[NSDate alloc] initWithTimeInterval:-OneDay*7 sinceDate:self.currentDate];
        [self switchWeek];
    }
}
- (IBAction)afterMonth:(id)sender {
    if (sender) {
        [self scrollEffect:RightMonth];
    }
    if (!sender) {
        self.currentDate = [[NSDate alloc] initWithTimeInterval:+OneDay*7*4 sinceDate:self.currentDate];
        [self switchWeek];
    }
}
- (IBAction)afterWeek:(id)sender {
    if (sender) {
        [self scrollEffect:RightWeek];
    }
    if (!sender) {
        self.currentDate = [[NSDate alloc] initWithTimeInterval:+OneDay*7 sinceDate:self.currentDate];
        [self switchWeek];
    }
}

#pragma mark- UICollectionViewDataSource

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.weekCollectionV]) {
        return 7;
    }
    if ([collectionView isEqual:self.scheduleCollV] ) {
        return self.timeSheetList.count * ((NSArray *) self.timeSheetList.firstObject).count;
    }
    
    if ([collectionView isEqual:self.beforeCollV] || [collectionView isEqual:self.behindCollV]) {
        return self.timeSheetList.count * ((NSArray *) self.timeSheetList.firstObject).count;

    }
    return 0;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.weekCollectionV]) {
        ZKDayCollCell *cell = (ZKDayCollCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZKDayCollCellID" forIndexPath:indexPath];
        ZKDayCollModel *model = self.weekArrM[indexPath.row];
        model.index = indexPath;
        cell.model = model;
        
        return cell;
    }
    
    if ([collectionView isEqual:self.scheduleCollV]) {
        ZKScheduleCell *cell = (ZKScheduleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZKScheduleCellID" forIndexPath:indexPath];
        if (self.isClear) {
            cell.isEmptyCell = YES;
            if(indexPath.row == self.timeSheetList.count * ((NSArray *) self.timeSheetList.firstObject).count - 1){
                self.isClear = NO;
            }
        }else{
            cell.isEmptyCell = NO;

            if (self.timeSheetList.count) {
                NSUInteger a = indexPath.row%7;
                NSUInteger b = indexPath.row/7;
                cell.scheduleModel = self.timeSheetList[a][b];
            }
        }
        return cell;
    }
    
    if ([collectionView isEqual:self.beforeCollV] || [collectionView isEqual:self.behindCollV]) {
        ZKScheduleCell *cell = (ZKScheduleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZKScheduleCellID" forIndexPath:indexPath];
        cell.isEmptyCell = YES;
        return cell;
    }
    return nil;
}

#pragma mark- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.timeArrM.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZKTimeCell *cell = (ZKTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"ZKTimeCellID" forIndexPath:indexPath];
    cell.lab.text = self.timeArrM[indexPath.row];
    return cell;
}

#pragma mark- UITableViewDataDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 41;
}

#pragma mark- UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    if (self.scheduleScrV.contentOffset.x < kScreenWidth - (self.timeTabW.constant+1) ) {
        self.type = LeftWeek;
        [self clearScheduleCollV];

    }else if (self.scheduleScrV.contentOffset.x > kScreenWidth - (self.timeTabW.constant+1) ){
        self.type = RightWeek;
        [self clearScheduleCollV];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    if (self.scheduleScrV.contentOffset.x == (kScreenWidth - (self.timeTabW.constant+1) ) *2) {
        self.type = RightWeek;
        [self clearScheduleCollV];
    
    }else if (self.scheduleScrV.contentOffset.x == 0){
        self.type = LeftWeek;
        [self clearScheduleCollV];
        
    }
}

-(void)clearScheduleCollV{
    self.isClear = YES;
    [self.scheduleCollV reloadData];
}

@end
