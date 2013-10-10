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


@import Foundation;


@class DMBatchNotificationManager;
@protocol DMBatchNotificationManagerDelegate;


@interface DMBatchNotificationManager : NSObject

@property (copy, nonatomic, readonly) NSArray *notificationNames;
@property (strong, nonatomic, readonly) id notificationSource;
@property (strong, nonatomic, readonly) dispatch_queue_t batchQueue;
@property (nonatomic, readonly) NSTimeInterval batchInterval;
@property (weak, nonatomic, readonly) id <DMBatchNotificationManagerDelegate> delegate;

// Setting batchQueue to nil will use the main queue
- (id)initWithNotifications:(NSArray *)notificationNames notificationSource:(id)notificationSource batchQueue:(dispatch_queue_t)batchQueue batchInterval:(NSTimeInterval)batchInterval delegate:(id <DMBatchNotificationManagerDelegate>)delegate;

@end


@protocol DMBatchNotificationManagerDelegate <NSObject>

- (void)batchNotificationManager:(DMBatchNotificationManager *)manager didReceiveNotifications:(NSArray *)notifications;

@end
