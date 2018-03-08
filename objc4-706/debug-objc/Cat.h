//
//  Cat.h
//  debug-objc
//
//  Created by xu yanjun on 2018/2/9.
//

#import "Animal.h"

@class Person;

@interface Cat : Animal

@property (weak, nonatomic) Person *owner;

@end
