// The MIT License (MIT)
//
// Copyright (c) 2013 Darren Mo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "DMBatchNotificationManager.h"


@interface DMBatchNotificationManager ()

@property (strong, nonatomic) dispatch_queue_t processingQueue;

@property (strong, nonatomic) NSMutableArray *notificationsReceived;

@property (strong, nonatomic) NSTimer *batchTimer;

@end


@implementation DMBatchNotificationManager

#pragma mark - Initialization/deallocation

- (id)initWithNotifications:(NSArray *)notificationNames notificationSource:(id)notificationSource batchQueue:(dispatch_queue_t)batchQueue batchInterval:(NSTimeInterval)batchInterval delegate:(id <DMBatchNotificationManagerDelegate>)delegate {
	NSParameterAssert(notificationNames);
	NSParameterAssert(batchInterval >= DBL_EPSILON);
	NSParameterAssert(delegate);
	
	
	self = [super init];
	
	if (self) {
		_notificationNames = [notificationNames copy];
		_notificationSource = notificationSource;
		_batchQueue = batchQueue ?: dispatch_get_main_queue();
		_batchInterval = batchInterval;
		_delegate = delegate;
		
		_notificationsReceived = [NSMutableArray array];
		
		
		_processingQueue = dispatch_queue_create("Batch Notification Manager Processing Queue", DISPATCH_QUEUE_SERIAL);
		
		
		_batchTimer = [NSTimer timerWithTimeInterval:self.batchInterval target:self selector:@selector(sendBatchMessage) userInfo:nil repeats:YES];
		
		NSAssert([NSThread isMainThread], @"DMBatchNotificationManager can only be used on the main thread.");
		[[NSRunLoop currentRunLoop] addTimer:self.batchTimer forMode:NSRunLoopCommonModes];
		
		
		for (NSString *notificationName in self.notificationNames) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:notificationName object:self.notificationSource];
		}
	}
	
	return self;
}

- (void)dealloc {
	NSAssert([NSThread isMainThread], @"DMBatchNotificationManager can only be used on the main thread.");
	
	
	for (NSString *notificationName in self.notificationNames) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:notificationName object:self.notificationSource];
	}
	
	
	// Fire one last time before invalidating
	[self.batchTimer fire];
	[self.batchTimer invalidate];
}

#pragma mark - Handling notifications

- (void)notificationReceived:(NSNotification *)notification {
	dispatch_async(self.processingQueue, ^{
		[self.notificationsReceived addObject:notification];
	});
}

#pragma mark - Delegating notifications

- (void)sendBatchMessage {
	__block NSArray *notifications;
	dispatch_sync(self.processingQueue, ^{
		notifications = [self.notificationsReceived copy];
		[self.notificationsReceived removeAllObjects];
	});
	
	
	if ([notifications count] == 0) return;
	
	
	dispatch_async(self.batchQueue, ^{
		[self.delegate batchNotificationManager:self didReceiveNotifications:notifications];
	});
}

@end
