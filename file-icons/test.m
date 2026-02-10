#import <Foundation/Foundation.h>

@interface TaskManager : NSObject

@property (nonatomic, strong) NSMutableArray<NSString *> *tasks;

- (instancetype)init;
- (void)addTask:(NSString *)task;
- (BOOL)removeTask:(NSString *)task;
- (NSArray<NSString *> *)allTasks;
- (NSUInteger)taskCount;

@end

@implementation TaskManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _tasks = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addTask:(NSString *)task {
    if (task.length > 0) {
        [self.tasks addObject:task];
        NSLog(@"Task added: %@", task);
    }
}

- (BOOL)removeTask:(NSString *)task {
    NSUInteger index = [self.tasks indexOfObject:task];
    if (index != NSNotFound) {
        [self.tasks removeObjectAtIndex:index];
        return YES;
    }
    return NO;
}

- (NSArray<NSString *> *)allTasks {
    return [self.tasks copy];
}

- (NSUInteger)taskCount {
    return self.tasks.count;
}

@end
