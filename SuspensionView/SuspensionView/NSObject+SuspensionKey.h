//
//  NSObject+SuspensionKey.h
//  SuspensionView
//
//  Created by Ossey on 2017/6/16.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SuspensionKey)

@property (nonatomic, copy) NSString *key;

- (NSString *)keyWithIdentifier:(NSString *)indetifier;

@end
