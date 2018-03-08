//
//  Person.h
//  objc
//
//  Created by 蓝布鲁 on 2016/12/29.
//
//

#import <Foundation/Foundation.h>

@class Cat;

@interface Person : NSObject

@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) Cat *pet;
@property (copy, nonatomic) void (^weekEndWork)();

+ (NSString *)species;
- (void)sayHello;
- (void)run;

@end
