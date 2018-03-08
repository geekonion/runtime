//
//  Animal.h
//  debug-objc
//
//  Created by xu yanjun on 2018/2/9.
//

#import <Foundation/Foundation.h>

@interface Animal : NSObject {
    int _publicIva;
}

@property (strong, nonatomic) NSString *name;

@property (class, strong, nonatomic) NSString *clsProperty;

@property (copy, nonatomic) void (^doSomething)();

- (void)run;
+ (void)clsMethod;

@end
