

#import "DateHelper.h"

@implementation DateHelper

+(NSCalendar *)calendar{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        calendar.timeZone = [NSTimeZone localTimeZone];
        
    });
    
    return calendar;
}

+(NSDateFormatter *)dateFormatter{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc]init];
        formatter.timeZone = [NSTimeZone localTimeZone];
    });
    
    return formatter;
}

+(NSString *)formaterDate:(NSTimeInterval)time andType:(TimeType)type{
    if (time == 0) {
        return @"";
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];

    NSDateComponents *comps = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSDateComponents *today = [self.calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    
    if (type == TimeStyleYearOnly) {
        self.dateFormatter.dateFormat = @"yyyy年";
    }else if (type == TimeStyleMonthOnly){
        self.dateFormatter.dateFormat = @"M月";
    }else if (type == TimeStyleDayOnly){
        self.dateFormatter.dateFormat = @"d日";
    }else if (type == TimeStyleHourOnly){
        self.dateFormatter.dateFormat = @"HH";
    }else if (type == TimeStyleMinuteOnly){
        self.dateFormatter.dateFormat = @"mm";
    }else if (type == TimeStyleSecondOnly){
        self.dateFormatter.dateFormat = @"ss";
    }else if (type == TimeStyleDateOnly){
        self.dateFormatter.dateFormat = @"yyyy年MM月dd日";
    }else if (type == TimeStyleTimeOnly){
        self.dateFormatter.dateFormat = @"HH:mm:ss";
    }else if (type == TimeStyleYearMonth){
        self.dateFormatter.dateFormat = @"yyyy年M月";
    }else if (type == TimeStyleMonthDay){
        self.dateFormatter.dateFormat = @"M月d日";
    }else if (type == TimeStyleDateAndTime){
        self.dateFormatter.dateFormat = @"M月d日 HH:mm";
    }else if (type == TimeStyleYearMonthOrMonthDay){
        if (comps.year == today.year) {
            self.dateFormatter.dateFormat = @"M月d日";
        }else{
            self.dateFormatter.dateFormat = @"yyyy年M月d日";
        }
    }
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    return dateString;
}
/**
 *  获取日期的月份和第几周
 *
 *  @param time <#time description#>
 *
 *  @return <#return value description#>
 */
+(NSString *)getIndexWeekOfMonth:(NSTimeInterval)time{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
//    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitMonth|NSWeekOfMonthCalendarUnit fromDate:date]; //NSWeekOfMonthCalendarUnit在8.0过期
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitMonth|NSCalendarUnitWeekOfMonth fromDate:date];
    return [NSString stringWithFormat:@"%ld月 第%ld周",(long)[dComponents month], (long)[dComponents weekOfMonth]];
}
/**
 *  @author john, 16-09-02 11:09:52
 *
 *  不同时区时间的转换
 */
+(NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate andAbbreviation:(NSString *)abbreviation
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:abbreviation];//@"UTC"或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    return destinationDateNow;
}
/**
 *  @author john, 16-09-02 11:09:47
 *
 *  判断两个时间是否是同一天
 */
+(BOOL)isSameDay:(NSTimeInterval)time1 With:(NSTimeInterval)time2 {
    
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:time1/1000];
    NSString *dateString1 = [self.dateFormatter stringFromDate:date1];
    
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:time2/1000];
    NSString *dateString2 = [self.dateFormatter stringFromDate:date2];
    
    return [dateString1 isEqualToString:dateString2];
}
/**
 *  @author john, 16-09-02 12:09:34
 *
 *  获取当前时间戳
 */
+(NSTimeInterval)now{
    return [DateHelper changeTime:[NSDate date]];
}

+(NSTimeInterval)changeTime:(NSDate *)date{
    NSTimeInterval time = date.timeIntervalSince1970*1000;
    return time;
}
/**
 *  @author john, 16-09-02 12:09:07
 *
 *  如果是今天返回今天、如果是昨天显示昨天、其他显示日期
 */
+(NSString *)dateCompare:(NSString *)date{
    
    NSTimeInterval timeInerval = [self changeTime:[NSDate date]];
    NSString *today = [self formaterDate:timeInerval andType:TimeStyleDateAndTime];
    NSString *str = [[today componentsSeparatedByString:@" "]firstObject];
    
    NSDate * yesterday = [[NSDate date] dateByAddingTimeInterval:-24*60*60];
    NSString *yesterdayStr = [self formaterDate:[self changeTime:yesterday] andType:TimeStyleDateAndTime];
    NSString *yesStr = [[yesterdayStr componentsSeparatedByString:@" "]firstObject];
    
    if ([date isEqualToString:str]) {
        return @"今天";
    }else if ([date isEqualToString:yesStr]){
        return @"昨天";
    }else{
        return date;
    }
}

+ (NSString *)stringTimesFromNow:(NSDate *)date{
    
    NSString *text = nil;
    
    NSDateComponents *components = [self.calendar components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:date toDate:[NSDate date] options:0];
    
    NSInteger agoCount = [self daysAgoCount:date];
    if (agoCount > 0) {
        if (agoCount == 1) {
            text = [NSString stringWithFormat:@"昨天"];
            return text;
        }else if (agoCount > 1){
            self.dateFormatter.dateFormat = @"yyyy年M月d日";
            NSString *dateString = [self.dateFormatter stringFromDate:date];
            return dateString;
        }
    }else{
        return @"今天";
        agoCount = components.hour;
        if (agoCount > 0) {
            text = [NSString stringWithFormat:@"%ld小时前", (long)agoCount];
        }else{
            agoCount = components.minute;
            if (agoCount > 0) {
                text = [NSString stringWithFormat:@"%ld分钟前", (long)agoCount];
            }else{
                agoCount = components.second;
                if (agoCount > 15) {
                    text = [NSString stringWithFormat:@"%ld秒前", (long)agoCount];
                }else{
                    text = @"刚刚";
                }
            }
        }
    }
    return text;
}
#pragma mark- 获取一周的时间段

+ (NSString *)getWeekOfDate:(NSTimeInterval)time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitWeekday|NSCalendarUnitYear fromDate:date];
    long dayNum = [dComponents weekday]>=2 ? [dComponents weekday] -1 : 7;
    NSDate *firstDate = [date dateByAddingTimeInterval: - (dayNum -1) * 60 * 60 * 24];
    NSDate *lastDate = [firstDate dateByAddingTimeInterval: 6 * 60 * 60 * 24];
    [self.dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    NSDateComponents *today = [self.calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
    if (dComponents.year == today.year) {
        [self.dateFormatter setDateFormat:@"M月d日"];
    }
    return [NSString stringWithFormat:@"%@—%@",[self.dateFormatter stringFromDate:firstDate],[self.dateFormatter stringFromDate:lastDate]];
}

+ (NSString *)getWeekPeriodOfDate:(NSTimeInterval)time weekPeriodType:(WeekPeriodFormatType)type
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSDateComponents * dComponents = [self.calendar components:NSCalendarUnitWeekday|NSCalendarUnitYear fromDate:date];
    long dayNum = [dComponents weekday]>=2 ? [dComponents weekday] -1 : 7;
    NSDate * firstDate = [date dateByAddingTimeInterval: - (dayNum -1) * 60 * 60 * 24];
    NSDate * lastDate = [firstDate dateByAddingTimeInterval: 6 * 60 * 60 * 24];
    
    if (type == WeekPeriod_ThisYearOnlyHaveMonthAndDay) {
        NSDateComponents * today = [self.calendar components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:[NSDate date]];
        [self.dateFormatter setDateFormat:@"yyyy年MM月dd日"];
        if (dComponents.year == today.year) {
            [self.dateFormatter setDateFormat:@"M月d日"];
        }
    } else if (type == WeekPeriod_OnlyMonthAndDay) {
        [self.dateFormatter setDateFormat:@"M月d日"];
    } else if (type == WeekPeriod_YearAndMonthAndDay) {
        [self.dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    }
    
    return [NSString stringWithFormat:@"%@—%@",[self.dateFormatter stringFromDate:firstDate],[self.dateFormatter stringFromDate:lastDate]];
}


+(NSTimeInterval)dayForWeek:(dateOfWeek)day{
    NSDate *date = [NSDate date];
    return [self dayForWeek:day date:date];
}

+(NSTimeInterval)dayForWeek:(dateOfWeek)day date:(NSDate*)date{
    
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSString *dateStr = [self.dateFormatter stringFromDate:date];
    NSDate *date1 = [self.dateFormatter dateFromString:dateStr];
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitWeekday|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    
    long dayNum = [dComponents weekday]>=2 ? [dComponents weekday] -1 : 7;
    NSDate *monday = [date1 dateByAddingTimeInterval: - (dayNum -1) * 60 * 60 * 24];
    NSDate *lastMonday = [monday dateByAddingTimeInterval:-7*60*60*24];
    NSDate *nextMonday = [monday dateByAddingTimeInterval:7*60*60*24];
    NSTimeInterval timeInterval;
    if (day == Monday) {
        timeInterval = [self changeTime:monday];
    }else if (day == LastMonday){
        timeInterval = [self changeTime:lastMonday];
    }else if (day == NextMonday){
        timeInterval = [self changeTime:nextMonday];
    }
    
    return timeInterval;
}

+(NSDictionary *)getCurrentWeekDay{
    
    NSDictionary *dict = nil;
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    if (dComponents.weekday == 1 || dComponents.weekday == 7) {
        dict = @{@"1":@"星期一"};
    }else{
        switch (dComponents.weekday) {
            case 2:
                dict = @{@"1":@"星期一"};
                break;
            case 3:
                dict = @{@"2":@"星期二"};
                break;
            case 4:
                dict = @{@"3":@"星期三"};
                break;
            case 5:
                dict = @{@"4":@"星期四"};
                break;
            case 6:
                dict = @{@"5":@"星期五"};
                break;
                
            default:
                break;
        }
    }
    return dict;
}

+(NSDictionary *)getCurrentWeekDayIncludeWeekend{
    
    NSDictionary *dict = nil;
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    
    switch (dComponents.weekday) {
        case 2:
            dict = @{@"1":@"星期一"};
            break;
        case 3:
            dict = @{@"2":@"星期二"};
            break;
        case 4:
            dict = @{@"3":@"星期三"};
            break;
        case 5:
            dict = @{@"4":@"星期四"};
            break;
        case 6:
            dict = @{@"5":@"星期五"};
            break;
        case 7:
            dict = @{@"6":@"星期六"};
            break;
        case 1:
            dict = @{@"7":@"星期日"};
            break;
            
        default:
            break;
    }
    
    return dict;
}

+(NSDictionary *)getMonthOfDate:(monthType)type andCurrentDate:(NSDate *)currentDate{
    
    NSDateComponents *dayComponent = [NSDateComponents new];
    
    if (type == LastMonth) {
        dayComponent.month = -1;
    }else if (type == NextMonth){
        dayComponent.month = 1;
    }else if (type == currentMonth){
        dayComponent.month = 0;
    }
    
    currentDate = [self.calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    
    NSString *month = [NSString stringWithFormat:@"%ld年%ld月",(long)comps.year,(long)comps.month];
    
    return @{kRetMonth:month,kRetCurrentDate:currentDate};
}

+(NSDate *)beginOfMonth:(NSDate *)date{
    NSDateComponents *componentsCurrentDate = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday|NSCalendarUnitWeekOfMonth fromDate:date];
    
    NSDateComponents *componentsNewDate = [NSDateComponents new];
    componentsNewDate.year = componentsCurrentDate.year;
    componentsNewDate.month = componentsCurrentDate.month;
    componentsNewDate.weekday = self.calendar.firstWeekday;
    
    NSDate *newDate = [self.calendar dateFromComponents:componentsNewDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    NSString *dateStr = [formatter stringFromDate:newDate];
    NSDate *beginDate = [formatter dateFromString:dateStr];
    return beginDate;
}

+(NSDate *)endOfMonth:(NSDate *)date{
    
    NSRange range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    NSDate *beginDate = [self beginOfMonth:date];
    
    NSDate *endDate = [beginDate dateByAddingTimeInterval:(range.length - 1) * 60*60*24];
    
    return endDate;
    
}

+ (NSUInteger)daysAgoCount {
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:[NSDate date]]];
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

+ (NSString *)stringTimesAgo:(NSDate *)date {
    
    NSString *text = nil;
    
    NSDateComponents *components = [self.calendar components:NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit fromDate:date toDate:[NSDate date] options:0];
    
    NSInteger agoCount = [self daysAgoCount];
    if (agoCount > 0) {
        text = [NSString stringWithFormat:@"%ld天前", (long)agoCount];
    }else{
        agoCount = components.hour;
        if (agoCount > 0) {
            text = [NSString stringWithFormat:@"%ld小时前", (long)agoCount];
        }else{
            agoCount = components.minute;
            if (agoCount > 0) {
                text = [NSString stringWithFormat:@"%ld分钟前", (long)agoCount];
            }else{
                agoCount = components.second;
                if (agoCount > 15) {
                    text = [NSString stringWithFormat:@"%ld秒前", (long)agoCount];
                }else{
                    text = @"刚刚";
                }
            }
        }
    }
    
    return text;
}

+ (NSUInteger)daysAgoCount:(NSDate *)date {
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *midnight = [self.dateFormatter dateFromString:[self.dateFormatter stringFromDate:date]];
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}





+ (NSDate *)lastMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = -1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

+ (NSDate*)nextMonth:(NSDate *)date
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.month = +1;
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

+ (NSInteger)day:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components day];
}

+ (NSInteger)month:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

+ (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}

+ (NSInteger)hour:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    return [components hour];
}

+ (NSInteger)minute:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|kCFCalendarUnitSecond) fromDate:date];
    return [components minute];
}

+ (NSString *)getYearAndMonthWithDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%ld年%.2ld月", (long)[DateHelper year:date], (long)[DateHelper month:date]];
}

+ (NSString *)getMonthAndDayWithDate:(NSDate *)date{
    return [NSString stringWithFormat:@"%ld/%ld", (long)[DateHelper month:date], (long)[DateHelper day:date]];

}

+ (NSString *)getYearAndMonthAndDayWithDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%ld年%.2ld月%ld日", (long)[DateHelper year:date], (long)[DateHelper month:date],(long)[DateHelper day:date]];
}

+ (NSInteger)currentDay:(NSTimeInterval)time
{
    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    return [DateHelper day:date];
}


/**
 * 开始到结束的时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(NSString *)startTime endTime:(NSString *)endTime{
    NSDateFormatter *date = [[NSDateFormatter alloc]init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *startD =[date dateFromString:startTime];
    NSDate *endD = [date dateFromString:endTime];
    NSTimeInterval start = [startD timeIntervalSince1970]*1;
    NSTimeInterval end = [endD timeIntervalSince1970]*1;
    NSTimeInterval value = end - start;
    int second = (int)value %60;//秒
    int minute = (int)value /60%60;
    int house = (int)value / (24 * 3600)%3600;
    int day = (int)value / (24 * 3600);
    NSString *str;
    if (day != 0) {
        str = [NSString stringWithFormat:@"耗时%d天%d小时%d分%d秒",day,house,minute,second];
    }else if (day==0 && house != 0) {
        str = [NSString stringWithFormat:@"耗时%d小时%d分%d秒",house,minute,second];
    }else if (day== 0 && house== 0 && minute!=0) {
        str = [NSString stringWithFormat:@"耗时%d分%d秒",minute,second];
    }else{
        str = [NSString stringWithFormat:@"耗时%d秒",second];
    }
    return str;
}

/**
 *  返回 月份
 *
 *  @param time
 *
 *  @return 月份
 */
+ (NSDictionary*)monthStringFromTimeInterval:(monthType)type andCurrentDate:(NSDate *)currentDate
{
 
    NSDateComponents *dayComponent = [NSDateComponents new];
    
    if (type == LastMonth) {
        dayComponent.month = -1;
    }else if (type == NextMonth){
        dayComponent.month = 1;
    }else if (type == currentMonth){
        dayComponent.month = 0;
    }
    
    currentDate = [self.calendar dateByAddingComponents:dayComponent toDate:currentDate options:0];
    
    NSDateComponents *comps = [self.calendar components:NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
    
    NSString *month = [NSString stringWithFormat:@"%ld月",(long)comps.month];
    
    return @{kRetMonth:month,kRetCurrentDate:currentDate};
}


+(NSTimeInterval)curentDayZeroDate:(NSDate*)date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = date;
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    NSDate *startDate = [calendar dateFromComponents:components];
  
    NSTimeInterval timeInterval = [self changeTime:startDate];
    return timeInterval;
    
}
//农历转换函数
+(NSString *)LunarForSolar:(NSDate *)solarDate{
    //天干名称
    NSArray *cTianGan = [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];
    
    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];
    
    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];
    
    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",
                         @"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",
                         @"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];
    
    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];
    
    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};
    
    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438
        ,3402,3749,331177,1453,694,201326,2350,465197,3221,3402
        ,400202,2901,1386,267611,605,2349,137515,2709,464533,1738
        ,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762
        ,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413
        ,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395
        ,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031
        ,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222
        ,268949,3402,3493,133973,1386,464219,605,2349,334123,2709
        ,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};
    
    static long wCurYear,wCurMonth,wCurDay;
    static long nTheDate,nIsEnd,m,k,n,i,nBit;
    
    //取当前公历年、月、日
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:solarDate];
    wCurYear = [components year];
    wCurMonth = [components month];
    wCurDay = [components day];
    
    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2))
        nTheDate = nTheDate + 1;
    
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1)
    {
        if(wNongliData[m] < 4095)
            k = 11;
        else
            k = 12;
        n = k;
        while(n>=0)
        {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for(i=1;i<n+1;i++)
                nBit = nBit/2;
            
            nBit = nBit % 2;
            
            if (nTheDate <= (29 + nBit))
            {
                nIsEnd = 1;
                break;
            }
            
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if(nIsEnd)
            break;
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n + 1;
    wCurDay = nTheDate;
    if (k == 12)
    {
        if (wCurMonth == wNongliData[m] / 65536 + 1)
            wCurMonth = 1 - wCurMonth;
        else if (wCurMonth > wNongliData[m] / 65536 + 1)
            wCurMonth = wCurMonth - 1;
    }
    
    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];
    
    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    }
    else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth];
    }
    
    NSString *lunarDate = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];
    
    return lunarDate;
}

+ (NSString *)getAstroWithMonth:(int)m day:(int)d
{
    NSString *astroString = @"魔羯水瓶双鱼白羊金牛双子巨蟹狮子处女天秤天蝎射手魔羯";
    NSString *astroFormat = @"102123444543";
    NSString *result;
    if (m<1||m>12||d<1||d>31){
        return @"错误日期格式!";
    }
    if(m==2 && d>29){
        return @"错误日期格式!!";
    }else if(m==4 || m==6 || m==9 || m==11) {
        if (d>30) {
            return @"错误日期格式!!!";
        }
    }
    result=[NSString stringWithFormat:@"%@",[astroString substringWithRange:NSMakeRange(m*2-(d < [[astroFormat substringWithRange:NSMakeRange((m-1), 1)] intValue] - (-19))*2,2)]];
    return result;
}

+ (NSString *)getAmimalWithYear:(int)year
{
    int zodiacSignsStart = 1804;
    NSArray * animals = @[@"鼠", @"牛", @"虎", @"兔", @"龙", @"蛇", @"马", @"羊", @"猴", @"鸡", @"狗", @"猪"];
    if(year < zodiacSignsStart){
        return @"未知";
    }
    return animals[(year - zodiacSignsStart) % animals.count];
}

//---------------爱智康----------------
+(NSString *)getDateFromStr:(NSString *)dateStr type:(TimeType)type{
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate * claStartDate = [dateformatter dateFromString:dateStr];
    NSString *str = [DateHelper formaterDate:[claStartDate timeIntervalSince1970]*1000 andType:type];
    
    return str;
}

+(NSString *)getCurrentWeekDayFrom:(NSString *)dateStr {
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSDate * claStartDate = [dateformatter dateFromString:dateStr];
    
    return [DateHelper getCurrentWeekDayWith:claStartDate];

}

+(NSString *)getCurrentWeekDayWith:(NSDate *)date{
    
    NSDateComponents *dComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:date];
    
    switch (dComponents.weekday) {
        case 2:
            return @"周一";
            break;
        case 3:
            return @"周二";
            break;
        case 4:
            return @"周三";
            break;
        case 5:
            return @"周四";
            break;
        case 6:
            return @"周五";
            break;
        case 7:
            return @"周六";
            break;
        case 1:
            return @"周日";
            break;
            
        default:
            break;
    }
    
    return @"";
}

+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];//只比较到日
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;

}
//比较两个日期的大小
+ (int)compareOneDayString:(NSString *)oneDay withAnotherDayString:(NSString *)anotherDay{
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//只比较到日
//    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
//    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDay];
    NSDate *dateB = [dateFormatter dateFromString:anotherDay];
    NSComparisonResult result = [dateA compare:dateB];
    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;

}

+ (NSString *)getYearAndMonthSlashStyleWithDate:(NSDate *)date
{
    return [NSString stringWithFormat:@"%ld/%ld", (long)[DateHelper year:date], (long)[DateHelper month:date]];
}

+(NSString *)getMMSSFromSS:(NSString *)totalTime{
    
    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}

@end
