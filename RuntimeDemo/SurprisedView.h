//
//  SurprisedView.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/11/6.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SurprisedViewDelegate <NSObject>

@required
- (void)changeValue:(NSString *)value;

@optional
- (void)changeBackgroundColor:(void(^)(UIColor *color))block;

@end

@interface SurprisedView : UIView

@property(nonatomic,weak)id<SurprisedViewDelegate> delegate;

- (NSString *)getAge;


@end

NS_ASSUME_NONNULL_END
