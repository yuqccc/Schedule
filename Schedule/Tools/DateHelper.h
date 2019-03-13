
#import <Foundation/Foundation.h>

#define kRetMonth @"month"
#define kRetCurrentDate @"currentDate"

@interface DateHelper : NSObject

typedef NS_ENUM(NSInteger, TimeType) {
    TimeStyleYearOnly, //只显示年份
    TimeStyleMonthOnly,
    TimeStyleDayOnly,
    
    TimeStyleHourOnly, //只显示小时
    TimeStyleMinuteOnly,
    TimeStyleSecondOnly,
    
    TimeStyleDateOnly, //只显示日期
    TimeStyleTimeOnly, //只显示时间
    
    TimeStyleYearMonth, //显示年月
    TimeStyleMonthDay, //显示月日
    TimeStyleDateAndTime, //日期和时间
    TimeStyleYearMonthOrMonthDay, //如果不是本年显示年月，如果是本年显示月日
};

typedef NS_ENUM(NSInteger, dateOfWeek) {
    Monday,
    LastMonday,
    NextMonday
};

typedef NS_ENUM(NSInteger, monthType) {
    currentMonth,
    LastMonth,
    NextMonth
};

typedef NS_ENUM(NSInteger, todayType) {
    Todayday,//今天
    Lastday,//上一天
    Nextday,//下一天
};

typedef NS_ENUM(NSInteger, ageFormatType) {
    simpleAge,
    completeAge
};

typedef NS_ENUM(NSInteger, WeekPeriodFormatType) {  // 获取周段的时间格式,不是本年的时候是否拼接年份
    WeekPeriod_OnlyMonthAndDay,             // xx月xx日--xx月xx日
    WeekPeriod_ThisYearOnlyHaveMonthAndDay, // thisYear:xx月xx日--xx月xx日 lastYear:xx年xx月xx日--xx年xx月xx日
    WeekPeriod_YearAndMonthAndDay           // xx年xx月xx日
};

+(NSString *)formaterDate:(NSTimeInterval)time andType:(TimeType)type;

+(NSString *)getIndexWeekOfMonth:(NSTimeInterval)time;

+(BOOL)isSameDay:(NSTimeInterval)time1 With:(NSTimeInterval)time2;

+(NSTimeInterval)now;
+(NSTimeInterval)changeTime:(NSDate *)date;
//+(NSDate *)getDateFromString:(NSString *)string andType:(timeStyle)type;

+(NSString *)dateCompare:(NSString *)date;

+(NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate andAbbreviation:(NSString *)abbreviatione;
#pragma mark- 获取一周的时间段
/**
 *  用 getWeekPeriodOfDate 方法的 WeekPeriod_HaveYear type 取代
 */
+ (NSString *)getWeekOfDate:(NSTimeInterval)time;
/**
 *  获取一周的时间段
 *
 *  @param time time
 *  @param type WeekPeriodFormatType
 *
 *  @return weekTimeStr
 */
+ (NSString *)getWeekPeriodOfDate:(NSTimeInterval)time weekPeriodType:(WeekPeriodFormatType)type;

/**
 *  获取本周、上周、下周的 mondayTime
 */
+(NSTimeInterval)dayForWeek:(dateOfWeek)day;
+(NSTimeInterval)dayForWeek:(dateOfWeek)day date:(NSDate*)date;

/**
 *  获取星期
 */
+(NSDictionary *)getCurrentWeekDay;
+(NSDictionary *)getCurrentWeekDayIncludeWeekend;

/**
 *  获取月份
 */
+(NSDictionary *)getMonthOfDate:(monthType)type andCurrentDate:(NSDate *)currentDate;
+(NSDate *)beginOfMonth:(NSDate *)date;
+(NSDate *)endOfMonth:(NSDate *)date;

/**
 *  上一个月的 date
 */
+ (NSDate *)lastMonth:(NSDate *)date;
/**
 *  下月的 date
 */
+ (NSDate*)nextMonth:(NSDate *)date;
/**
 *  获取 date 的月、日、年
 */
+ (NSInteger)day:(NSDate *)date;
+ (NSInteger)month:(NSDate *)date;
+ (NSInteger)year:(NSDate *)date;
+ (NSInteger)hour:(NSDate *)date;
+ (NSInteger)minute:(NSDate *)date;
/**
 *  获取 年月
 */
+ (NSString *)getYearAndMonthWithDate:(NSDate *)date;
/**
 *  获取 月日
 */
+ (NSString *)getMonthAndDayWithDate:(NSDate *)date;
/**
 *  获取 年月日
 */
+ (NSString *)getYearAndMonthAndDayWithDate:(NSDate *)date;

/**
 *  多长时间前；比如”3天前“
 */
+ (NSString *)stringTimesAgo:(NSDate *)date;
+ (NSString *)stringTimesFromNow:(NSDate *)date;
/**
 *  时间差
 */
+ (NSString *)dateTimeDifferenceWithStartTime:(long long)startTime endTime:(long long)endTime;

/**
 *  返回 星期几 年-月-日
 *
 *  @param time
 *
 *  @return 星期几 年-月-日
 */
+ (NSString*)weekdayAndDateStringFromTimeInterval:(NSTimeInterval)time andType:(todayType)type;
/**
 *  返回 月份
 *
 *  @param time
 *
 *  @return 月份
 */
+ (NSDictionary*)monthStringFromTimeInterval:(monthType)type andCurrentDate:(NSDate *)currentDate;
/**
 *  获取时间的0点0分0秒
 *
 *  @param date <#date description#>
 *
 *  @return <#return value description#>
 */
+(NSTimeInterval)curentDayZeroDate:(NSDate*)date;

//---------------爱智康----------------
+(NSString *)getDateFromStr:(NSString *)dateStr type:(TimeType)type;
+(NSString *)getCurrentWeekDayFrom:(NSString *)dateStr;
+(NSString *)getCurrentWeekDayWith:(NSDate *)date;
//比较两个日期的大小
+ (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay;
//比较两个日期的大小
+ (int)compareOneDayString:(NSString *)oneDay withAnotherDayString:(NSString *)anotherDay;

+ (NSString *)getYearAndMonthSlashStyleWithDate:(NSDate *)date;
//把秒转换成时分秒
+(NSString *)getMMSSFromSS:(NSString *)totalTime;


@end
