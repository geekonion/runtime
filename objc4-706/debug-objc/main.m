//
//  main.m
//  debug-objc
//
//  Created by 蓝布鲁 on 2016/12/29.
//
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Cat.h"
#import "Son.h"

id (*method)(id, SEL, ...);

IMP class_getMethodImplementation(Class cls, SEL sel);

void runtimeTest();
void sarkTest();

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        //测试运行时
//        runtimeTest();
        
        sarkTest();
    }
    return 0;
}

void sarkTest() {
    Son *son = [Son new];
    
    [son paly];
}

void runtimeTest() {
    /*待测试:
     1.类的创建时机和过程，怎么标识类是类型，普通对象为什么不能当作类型来用(系统类什么时候创建，NSObject是什么时候创建的，其他辅助类)
     2.每个类的元类的创建时机和过程
     3.类方法和对象方法怎么统一到一起的(底层会调用同一个函数)，调用类方法的时候，类对象的isa里面是什么呢。（元类存在的意义）
     
     思考结果：
     1和2.编译时生成，被写入Mach-0文件的不同区块，运行时，在_read_images()的_getObjc2ClassList()加载进内存
     clang -rewrite-objc /Users/xuyanjun/objc4-706/debug-objc/Animal.m，其中生成的类相关的代码(即下面第3).部分)在最底部
     
     1).让Animal成为类型，实际上还是struct objc_object，并没有新的类产生
     typedef struct objc_object Animal;
     
     2).生成类的实现，及方法的实现
     //声明属性偏移量OBJC_IVAR_$_Animal$_name，在-setName:和-name方法中会用到
     extern "C" unsigned long OBJC_IVAR_$_Animal$_name;
     extern "C" unsigned long OBJC_IVAR_$_Animal$_doSomething;
     
     //类的实现
     struct Animal_IMPL {
        struct NSObject_IMPL NSObject_IVARS;
        int _publicIva;
        int _privateIva1;
        int _privateIva2;
        NSString *_name;
        void (*_doSomething)();
     };
     
     //类属性没有做任何处理
     @property (class, strong, nonatomic) NSString *clsProperty;
     
     //run方法的实现
     static void _I_Animal_run(Animal * self, SEL _cmd) {
        ((Class (*)(id, SEL))(void *)objc_msgSend)((id)self, sel_registerName("class"));
        //[super class]调用
        //objc_msgSendSuper第一个参数是__rw_objc_super类型，其中的receiver字段是self，所以最终调用的self的class方法
        ((Class (*)(__rw_objc_super *, SEL))(void *)objc_msgSendSuper)((__rw_objc_super){(id)self, (id)class_getSuperclass(objc_getClass("Animal"))}, sel_registerName("class"));
     }
     
     //clsMethod方法的实现
     static void _C_Animal_clsMethod(Class self, SEL _cmd) {
     
     }
     
     static void _I_Animal_dealloc(Animal * self, SEL _cmd) {
     
     }
     
     //name的setter和getter方法的实现
     static NSString * _I_Animal_name(Animal * self, SEL _cmd) { return (*(NSString **)((char *)self + OBJC_IVAR_$_Animal$_name)); }
     //注意和-setDoSomething:实现的区别
     static void _I_Animal_setName_(Animal * self, SEL _cmd, NSString *name) { (*(NSString **)((char *)self + OBJC_IVAR_$_Animal$_name)) = name; }
     
     //doSomething的getter方法的实现
     static void(* _I_Animal_doSomething(Animal * self, SEL _cmd) )(){ return (*(void (**)())((char *)self + OBJC_IVAR_$_Animal$_doSomething)); }
     
     extern "C" __declspec(dllimport) void objc_setProperty (id, SEL, long, id, bool, bool);
     
     //doSomething的setter方法的实现，注意和-setName:实现的区别
     static void _I_Animal_setDoSomething_(Animal * self, SEL _cmd, void (*doSomething)()) { objc_setProperty (self, _cmd, __OFFSETOFIVAR__(struct Animal, _doSomething), (id)doSomething, 0, 1); }
     
     3).定义struct _ivar_t 、struct _class_ro_t 和 struct _class_t及其他需要的类型
     struct _ivar_t {
        unsigned long int *offset;  // pointer to ivar offset location
        const char *name;
        const char *type;
        unsigned int alignment;
        unsigned int  size;
     };
     
     struct _class_ro_t {
        unsigned int flags;
        unsigned int instanceStart;
        unsigned int instanceSize;
        unsigned int reserved;
        const unsigned char *ivarLayout;
        const char *name;
        const struct _method_list_t *baseMethods;
        const struct _objc_protocol_list *baseProtocols;
        const struct _ivar_list_t *ivars;
        const unsigned char *weakIvarLayout;
        const struct _prop_list_t *properties;
     };
     
     struct _class_t {
        struct _class_t *isa;
        struct _class_t *superclass;
        void *cache;
        void *vtable;
        struct _class_ro_t *ro;
     };
     
     4).生成类、元类（静态变量）
     
     //__attribute__的section子项的使用格式为：__attribute__((section("section_name")))
     //其作用是将作用的函数或数据放入指定名为"section_name"输入段。这里的输入段是相对于Link程序来说的，Link程序的输出段对应可执行文件或库的输入段
     //Link程序会根据一定的规则，将不同的输入段重新组合到不同的输出段中，输入段和输出段可以完全不同。
     
     //记录ivar的地址，可以看出在不同地方第一的ivar和property生成的ivar本质上是没有任何区别的，没有属性和ivar，则不会生成
     extern "C" unsigned long int OBJC_IVAR_$_Animal$_publicIva __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Animal, _publicIva);
     extern "C" unsigned long int OBJC_IVAR_$_Animal$_privateIva1 __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Animal, _privateIva1);
     extern "C" unsigned long int OBJC_IVAR_$_Animal$_privateIva2 __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Animal, _privateIva2);
     extern "C" unsigned long int OBJC_IVAR_$_Animal$_name __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Animal, _name);
     extern "C" unsigned long int OBJC_IVAR_$_Animal$_doSomething __attribute__ ((used, section ("__DATA,__objc_ivar"))) = __OFFSETOFIVAR__(struct Animal, _doSomething);
     
     //创建ivar列表_OBJC_$_INSTANCE_VARIABLES_Animal，没有属性和ivar，则不会生成
     static struct { //_ivar_list_t
        unsigned int entsize;  // sizeof(struct _prop_t)
        unsigned int count;
        struct _ivar_t ivar_list[5];
     } _OBJC_$_INSTANCE_VARIABLES_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_ivar_t),
        5,
        {{(unsigned long int *)&OBJC_IVAR_$_Animal$_publicIva, "_publicIva", "i", 2, 4},
        {(unsigned long int *)&OBJC_IVAR_$_Animal$_privateIva1, "_privateIva1", "i", 2, 4},
        {(unsigned long int *)&OBJC_IVAR_$_Animal$_privateIva2, "_privateIva2", "i", 2, 4},
        {(unsigned long int *)&OBJC_IVAR_$_Animal$_name, "_name", "@\"NSString\"", 3, 8},
        {(unsigned long int *)&OBJC_IVAR_$_Animal$_doSomething, "_doSomething", "@?", 3, 8}}
     };
     
     //创建Animal对象方法列表_OBJC_$_INSTANCE_METHODS_Animal，如果没有对象方法，则不生成
     static struct { //_method_list_t
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[6];
     } _OBJC_$_INSTANCE_METHODS_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        6,
        {{(struct objc_selector *)"run", "v16@0:8", (void *)_I_Animal_run},
        {(struct objc_selector *)"dealloc", "v16@0:8", (void *)_I_Animal_dealloc},
        {(struct objc_selector *)"name", "@16@0:8", (void *)_I_Animal_name},
        {(struct objc_selector *)"setName:", "v24@0:8@16", (void *)_I_Animal_setName_},
        {(struct objc_selector *)"doSomething", "@?16@0:8", (void *)_I_Animal_doSomething},
        {(struct objc_selector *)"setDoSomething:", "v24@0:8@?16", (void *)_I_Animal_setDoSomething_}}
     };
     
     //创建Animal类方法列表_OBJC_$_INSTANCE_METHODS_Animal，如果没有类方法，则不生成
     static struct { //_method_list_t
        unsigned int entsize;  // sizeof(struct _objc_method)
        unsigned int method_count;
        struct _objc_method method_list[1];
     } _OBJC_$_CLASS_METHODS_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_objc_method),
        1,
        {{(struct objc_selector *)"clsMethod", "v16@0:8", (void *)_C_Animal_clsMethod}}
     };
     
     //创建propertyList _OBJC_$_PROP_LIST_Animal，没有property，则不生成
     static struct { //_prop_list_t
        unsigned int entsize;  // sizeof(struct _prop_t)
        unsigned int count_of_properties;
        struct _prop_t prop_list[2];
     } _OBJC_$_PROP_LIST_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        sizeof(_prop_t),
        2,
        {{"name","T@\"NSString\",&,N,V_name"},
        {"doSomething","T@?,C,N,V_doSomething"}}
     };
     
     //创建Animal的只读元类
     static struct _class_ro_t _OBJC_METACLASS_RO_$_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        1, sizeof(struct _class_t), sizeof(struct _class_t),
        (unsigned int)0,
        0,
        "Animal",
        (const struct _method_list_t *)&_OBJC_$_CLASS_METHODS_Animal, //如果没有类方法，则这里是0
        0,
        0,
        0,
        0,
     };
     
     //创建Animal只读类
     static struct _class_ro_t _OBJC_CLASS_RO_$_Animal __attribute__ ((used, section ("__DATA,__objc_const"))) = {
        0, sizeof(struct Animal_IMPL), sizeof(struct Animal_IMPL),
        (unsigned int)0,
        0,
        "Animal",
        (const struct _method_list_t *)&_OBJC_$_INSTANCE_METHODS_Animal, //如果没有对象方法，则这里是0
        0,
        (const struct _ivar_list_t *)&_OBJC_$_INSTANCE_VARIABLES_Animal,
        0,
        (const struct _prop_list_t *)&_OBJC_$_PROP_LIST_Animal,
     };
     
     //在要输入的函数、类、数据的声明前加上__declspec(dllimport)的修饰符，表示输入，函数是从其他模块导入的
     //在要输出的函数、类、数据的声明前加上__declspec(dllexport)的修饰符，表示输出，供其他模块使用
     
     //声明NSObject元类，并不赋值（重复声明的意义: 在不同地方可以获取到同一个变量，而不需要管它定义在哪里）
     extern "C" __declspec(dllimport) struct _class_t OBJC_METACLASS_$_NSObject;
     
     //创建Animal元类
     extern "C" __declspec(dllexport) struct _class_t OBJC_METACLASS_$_Animal __attribute__ ((used, section ("__DATA,__objc_data"))) = {
        0, // &OBJC_METACLASS_$_NSObject,
        0, // &OBJC_METACLASS_$_NSObject,
        0, // (void *)&_objc_empty_cache,                   //初始化时，缓存是空的
        0, // unused, was (void *)&_objc_empty_vtable,
        &_OBJC_METACLASS_RO_$_Animal,                       //关联Animal的只读元类
     };
     
     //声明NSObject类，并不赋值
     extern "C" __declspec(dllimport) struct _class_t OBJC_CLASS_$_NSObject;
     
     //创建Animal类
     extern "C" __declspec(dllexport) struct _class_t OBJC_CLASS_$_Animal __attribute__ ((used, section ("__DATA,__objc_data"))) = {
        0, // &OBJC_METACLASS_$_Animal,
        0, // &OBJC_CLASS_$_NSObject,
        0, // (void *)&_objc_empty_cache,
        0, // unused, was (void *)&_objc_empty_vtable,
        &_OBJC_CLASS_RO_$_Animal,                       //关联Animal只读类
     };
     
     //定义Animal类的初始化方法
     static void OBJC_CLASS_SETUP_$_Animal(void ) {
        //初始化Animal元类的isa、superclass、cache属性
        OBJC_METACLASS_$_Animal.isa = &OBJC_METACLASS_$_NSObject;
        OBJC_METACLASS_$_Animal.superclass = &OBJC_METACLASS_$_NSObject;
        OBJC_METACLASS_$_Animal.cache = &_objc_empty_cache;
     
        //初始化Animal类的isa、superclass、cache属性
        OBJC_CLASS_$_Animal.isa = &OBJC_METACLASS_$_Animal;
        OBJC_CLASS_$_Animal.superclass = &OBJC_CLASS_$_NSObject;
        OBJC_CLASS_$_Animal.cache = &_objc_empty_cache;
     }
     
     5).创建数据段
     //#pragma section 创建一个段。
     //其格式为：#pragma section("section-name" [, attributes] )
     //在创建了段之后，还要使用__declspec(allocate("section-name"))将代码或数据放入段中。
     
     #pragma section(".objc_inithooks$B", long, read, write)
     //将各个类的初始化方法，放到OBJC_CLASS_SETUP数组里
     __declspec(allocate(".objc_inithooks$B")) static void *OBJC_CLASS_SETUP[] = {
        (void *)&OBJC_CLASS_SETUP_$_Animal,
     };
     
     
     //将Animal类放入L_OBJC_LABEL_CLASS_$数组，写入__objc_classlist段
     static struct _class_t *L_OBJC_LABEL_CLASS_$ [1] __attribute__((used, section ("__DATA, __objc_classlist,regular,no_dead_strip")))= {
        &OBJC_CLASS_$_Animal,
     };
     //创建类对应的IMAGE_INFO？
     static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
     
     3.对象方法：对象的isa指针中shiftcls存的是类的地址，去类的cache属性中查找，如果没找到，则去bits属性里去查找，必要时用superclass属性，向上查找
     类方法：类的isa指针中shiftcls存的是元类的地址，去元类的cache属性中查找，如果没找到，则去bits属性里去查找，必要时用superclass属性，向上查找
     */
    
    //_objc_init runtime初始化方法
    //objc-os.mm _objc_init下断点(或符号断点)，测试runtime初始化，lldb bt命令查看调用栈，注册map_2_images、load_images和unmap_image
    
    //然后会反复调用objc-runtime-new.mm中的map_2_images和load_images加载
    //map_2_images
    //load_images 1.Discover load methods 2.Call +load methods (without runtimeLock - re-entrant)
    
    Person *person = [[Person alloc] init];
    [person performSelector:@selector(sayHello)];
    //测试isRealized
    Person *person2 = [[Person alloc] init];
    //测试new的调用
    Person *person3 = [Person new];
    
    //copy：会调用void objc_setProperty_nonatomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset)，这个函数里有对(non)atomic的处理
    person.name = @"NO.1";
    person.weekEndWork = ^{
        NSLog(@"weekEndWork");
    };
    
    NSLog(@"%@", [Person performSelector:@selector(species)]);
    
    Cat *cat = [[Cat alloc] init];
    
    /*给weak属性赋值，会调用storeWeak函数
     template <bool HaveOld, bool HaveNew, bool CrashIfDeallocating>
     static id
     storeWeak(id *location, objc_object *newObj)*/
    cat.owner = person;
    
    /*
     id objc_storeWeakOrNil(id *location, id newObj)
     */
    person.pet = cat;
    
    //调用weak_unregister_no_lock清理之前的值
    cat.owner = person2;
    
    /*
     创建：调用id objc_initWeak(id *location, id newObj)
     objc_initWeak中也会调用storeWeak函数
     销毁：调用void objc_release(id obj)
     */
    __weak Person *person4 = [[Person alloc] init];
    
    //测试正常消息发送
    method = class_getMethodImplementation([Cat class], @selector(run));
    (*method)(cat, @selector(run));
    
    //测试完整消息机制 决断、转发
    method = class_getMethodImplementation([Cat class], @selector(read));
    //        (*method)(cat, @selector(read));
}
