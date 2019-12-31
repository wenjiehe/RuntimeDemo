//
//  StudentModel.h
//  RuntimeDemo
//
//  Created by 贺文杰 on 2019/12/29.
//  Copyright © 2019 贺文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TeacherModel;

@interface ClassModel : NSObject

@property(nonatomic,copy)NSString *name; /**< 班级名称 */
@property(nonatomic,copy)NSString *code; /**< 班级编号 */
@property(nonatomic,strong)NSArray *list;
@property(nonatomic,strong)TeacherModel *teacher;

@end

@interface TeacherModel : NSObject

@property(nonatomic,copy)NSString *name; /**< 老师姓名 */
@property(nonatomic,copy)NSString *sex; /**< 老师性别 */

@end

@interface StudentModel : NSObject

@property(nonatomic,copy)NSString *name; /**< 学生姓名 */
@property(nonatomic,copy)NSString *age; /**< 学生年龄  */
@property(nonatomic,strong)TeacherModel *teacher;

@end

NS_ASSUME_NONNULL_END
